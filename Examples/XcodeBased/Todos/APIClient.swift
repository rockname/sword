import Foundation
import Sword

@Dependency(
  registeredTo: AppComponent.self,
  scopedWith: .single
)
final class APIClient {
  private let urlSession: URLSession
  private let jsonDecoder: JSONDecoder

  @Injected
  init(
    urlSession: URLSession,
    jsonDecoder: JSONDecoder
  ) {
    self.urlSession = urlSession
    self.jsonDecoder = jsonDecoder
  }
}
