import DataModel
import Foundation
import SwiftUI

public struct HomeScreen: View {
  private let viewModel: HomeViewModel
  private let onPostTapped: (Post.ID) -> Void

  public init(
    viewModel: HomeViewModel,
    onPostTapped: @escaping (Post.ID) -> Void
  ) {
    self.viewModel = viewModel
    self.onPostTapped = onPostTapped
  }

  public var body: some View {
    HomeContent(
      uiState: viewModel.uiState,
      onPostTapped: onPostTapped
    )
    .task {
      await viewModel.onAppear()
    }
  }
}

struct HomeContent: View {
  let uiState: HomeUIState
  let onPostTapped: (Post.ID) -> Void

  var body: some View {
    ZStack {
      switch uiState {
      case .initial:
        ZStack {}
      case .loading:
        ProgressView()
      case .success(let posts):
        List(posts) { post in
          Button(
            action: {
              onPostTapped(post.id)
            },
            label: {
              VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 4) {
                  Text(post.username)
                    .font(.headline)
                  Text("-")
                  Text("just now")
                    .font(.subheadline)
                }
                Text(post.content)
                  .font(.body)
                HStack(spacing: 8) {
                  Image(systemName: "bubble.right")
                  Spacer()
                  Image(systemName: "square.and.arrow.up")
                  Spacer()
                  Image(systemName: "ellipsis")
                }
              }
              .tint(.primary)
            }
          )
        }
      case .error:
        Text("Failed to load posts")
      }
    }
    .navigationTitle("Home")
  }
}

extension Post: Identifiable {
}

#Preview {
  HomeContent(
    uiState: .success(
      [
        Post(
          id: .init(value: UUID().uuidString),
          username: "rockname",
          content: "Example post"
        )
      ]
    ),
    onPostTapped: { _ in }
  )
}
