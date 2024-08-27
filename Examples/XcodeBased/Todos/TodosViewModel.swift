import ComponentApp
import Observation
import Sword

enum TodosUIState {
  case initial
  case loading
  case success([Todo])
  case error
}

@Dependency(registeredTo: AppComponent.self)
@Observable
@MainActor
final class TodosViewModel {
  private(set) var uiState: TodosUIState = .initial

  private let todosRepository: TodosRepository

  @Injected
  init(todosRepository: TodosRepository) {
    self.todosRepository = todosRepository
  }

  func onAppear() async {
    guard case .initial = uiState else { return }

    await loadTodos()
  }

  private func loadTodos() async {
    uiState = .loading
    do {
      let todos = try await todosRepository.fetchTodos()
      uiState = .success(todos)
    } catch {
      uiState = .error
    }
  }
}
