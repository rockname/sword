import ComponentUser
import DataModel
import SwiftUI
import UIHome
import UIPostDetail

enum HomeNavigationRoute: Hashable {
  case postDetail(id: Post.ID)
}

struct HomeNavigation: View {
  @State private var navigationPath = [HomeNavigationRoute]()

  let component: UserComponent
  let onLoggedIn: () -> Void

  var body: some View {
    NavigationStack(path: $navigationPath) {
      HomeScreen(
        viewModel: component.homeViewModel,
        onPostTapped: { id in
          navigationPath.append(.postDetail(id: id))
        }
      )
      .navigationDestination(for: HomeNavigationRoute.self) { route in
        switch route {
        case .postDetail(let id):
          PostDetailScreen(
            viewModel: component.postDetailViewModel(id)
          )
        }
      }
    }
  }
}
