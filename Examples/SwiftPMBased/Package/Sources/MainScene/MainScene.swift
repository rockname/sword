import ComponentApp
import DataModel
import SwiftUI

public struct MainScene: Scene {
  private let component: AppComponent

  public init(baseURL: URL) {
    self.component = AppComponent(
      envVars: EnvVars(baseURL: baseURL)
    )
  }

  public var body: some Scene {
    WindowGroup {
      RootNavigation(component: component)
    }
  }
}
