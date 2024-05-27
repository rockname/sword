import SwiftUI

@main
struct TodosApp: App {
  let component = AppComponent()

  var body: some Scene {
    WindowGroup {
      TodosScreen(viewModel: component.todosViewModel)
    }
  }
}
