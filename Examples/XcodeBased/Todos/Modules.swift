import Foundation
import Sword

@Module(registeredTo: AppComponent.self)
struct AppModule {
  @Provider(scopedWith: .single)
  static func urlSession() -> URLSession {
    .shared
  }

  @Provider(scopedWith: .single)
  static func jsonDecoder() -> JSONDecoder {
    JSONDecoder()
  }
}
