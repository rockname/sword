import ComponentUser
import DataAPIClient
import DataModel
import Foundation
import Sword

@Dependency(registeredTo: UserComponent.self)
public struct HomeTimelineRepository: Sendable {
  private let apiClient: APIClient

  @Injected
  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func fetchInitialTimeline() async throws -> [Post] {
    try await Task.sleep(for: .seconds(1))
    return (1...50).map {
      Post(
        id: .init(value: UUID().uuidString),
        username: "rockname",
        content: "Post \($0)"
      )
    }
  }
}
