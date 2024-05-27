import SwiftUI

struct TodosScreen: View {
  let viewModel: TodosViewModel

  var body: some View {
    TodosContent(
      uiState: viewModel.uiState
    )
    .task {
      await viewModel.onAppear()
    }
  }
}

private struct TodosContent: View {
  let uiState: TodosUIState

  var body: some View {
    switch uiState {
    case .initial:
      ZStack {}
    case .loading:
      ProgressView()
    case .success(let todos):
      List(todos) { todo in
        HStack(spacing: 8) {
          Image(
            systemName: todo.hasDone ? "checkmark.circle.fill" : "circle"
          )
          .resizable()
          .frame(width: 20, height: 20)
          Text(todo.title)
        }
      }
    case .error:
      Text("Failed to load todos")
    }
  }
}

#Preview {
  TodosContent(
    uiState: .success([
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
    ])
  )
}
