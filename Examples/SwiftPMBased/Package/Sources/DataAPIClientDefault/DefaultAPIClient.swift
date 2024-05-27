import ComponentApp
import DataAPIClient
import DataModel
import Foundation
import Sword

@Dependency(
  registeredTo: AppComponent.self,
  boundTo: APIClient.self
)
public struct DefaultAPIClient: APIClient {
  private let baseURL: URL
  private let urlSession: URLSession
  private let jsonDecoder: JSONDecoder

  @Injected
  public init(
    envVars: EnvVars,
    urlSession: URLSession,
    jsonDecoder: JSONDecoder
  ) {
    self.baseURL = envVars.baseURL
    self.urlSession = urlSession
    self.jsonDecoder = jsonDecoder
  }
}
