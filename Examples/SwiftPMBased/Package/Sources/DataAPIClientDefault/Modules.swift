import ComponentApp
import DataModel
import Foundation
import Sword

@Module(registeredTo: AppComponent.self)
public struct AppModule {
  @Provider(scopedWith: .single)
  public static func urlSession(envVars: EnvVars) -> URLSession {
    .shared
  }

  @Provider
  public static func jsonDecoder() -> JSONDecoder {
    JSONDecoder()
  }
}
