import DataModel
import SwiftUI

public struct PostDetailScreen: View {
  private let viewModel: PostDetailViewModel

  public init(viewModel: PostDetailViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    PostDetailContent(
      uiState: viewModel.uiState
    )
    .task {
      await viewModel.onAppear()
    }
  }
}

struct PostDetailContent: View {
  let uiState: PostDetailUIState

  var body: some View {
    ZStack {
      switch uiState {
      case .initial:
        ZStack {}
      case .loading:
        ProgressView()
      case .success(let post):
        ZStack(alignment: .top) {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(16)
      case .error:
        Text("Failed to load the post")
      }
    }
    .navigationTitle("Detail")
  }
}

#Preview {
  NavigationStack {
    PostDetailContent(
      uiState: .success(
        Post(
          id: .init(value: UUID().uuidString),
          username: "rockname",
          content: "Post"
        )
      )
    )
  }
}
