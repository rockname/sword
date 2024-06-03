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
final class TodosViewModel {
  @MainActor
  private(set) var uiState: TodosUIState = .initial

  private let todosRepository: TodosRepository

  @Injected
  init(todosRepository: TodosRepository) {
    self.todosRepository = todosRepository
  }

  @MainActor
  func onAppear() async {
    guard case .initial = uiState else { return }

    await loadTodos()
  }

  @MainActor
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
