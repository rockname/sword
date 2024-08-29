import ComponentUser
import DataModel
import DataRepository
import Observation
import Sword

enum PostDetailUIState {
  case initial
  case loading
  case success(Post)
  case error
}

@Dependency(registeredTo: UserComponent.self)
@Observable
@MainActor
public final class PostDetailViewModel {
  private(set) var uiState: PostDetailUIState = .initial

  private let id: Post.ID
  private let postRepository: PostRepository

  @Injected
  public init(
    @Assisted id: Post.ID,
    postRepository: PostRepository
  ) {
    self.id = id
    self.postRepository = postRepository
  }

  func onAppear() async {
    guard case .initial = uiState else { return }

    await loadPost()
  }

  private func loadPost() async {
    uiState = .loading
    do {
      let post = try await postRepository.fetchPost(id: id)
      uiState = .success(post)
    } catch {
      uiState = .error
    }
  }
}
