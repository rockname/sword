import ComponentUser
import DataAPIClient
import DataModel
import Sword

@Dependency(registeredTo: UserComponent.self)
public class PostRepository {
  private let apiClient: APIClient

  @Injected
  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func fetchPost(id: Post.ID) async throws -> Post {
    try await Task.sleep(for: .seconds(1))
    return Post(
      id: id,
      username: "rockname",
      content: "Post"
    )
  }
}
