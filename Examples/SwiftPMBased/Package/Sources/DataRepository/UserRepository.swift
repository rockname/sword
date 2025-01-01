import ComponentApp
import DataAPIClient
import Foundation
import Sword

@Dependency(
  registeredTo: AppComponent.self,
  scopedWith: .single
)
public final class UserRepository: Sendable {
  private let apiClient: APIClient

  public var isUserLoggedIn: Bool {
    false
  }

  @Injected
  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func registerUser(
    username: String,
    password: String
  ) async throws {
    try await Task.sleep(for: .seconds(1))
  }
}
