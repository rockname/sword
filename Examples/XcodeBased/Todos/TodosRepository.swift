import Foundation
import Sword

@Dependency(registeredTo: AppComponent.self)
struct TodosRepository {
  private let apiClient: APIClient

  @Injected
  init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  func fetchTodos() async throws -> [Todo] {
    try await Task.sleep(for: .seconds(1))
    return [
      Todo(
        id: .init(value: UUID().uuidString),
        title: "Read a book",
        hasDone: true
      ),
      Todo(
        id: .init(value: UUID().uuidString),
        title: "Go to the gym",
        hasDone: false
      ),
      Todo(
        id: .init(value: UUID().uuidString),
        title: "Buy a coffee",
        hasDone: false
      ),
    ]
  }
}
