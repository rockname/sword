import ComponentApp
import Foundation
import Sword

@Module(registeredTo: AppComponent.self)
public struct AppModule {
  @Provider(scopedWith: .single)
  public static func urlSession() -> URLSession {
    .shared
  }

  @Provider(scopedWith: .single)
  public static func jsonDecoder() -> JSONDecoder {
    JSONDecoder()
  }
}
