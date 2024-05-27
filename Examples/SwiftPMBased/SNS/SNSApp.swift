import MainScene
import SwiftUI

@main
struct SNSApp: App {
  var body: some Scene {
    MainScene(baseURL: URL(string: "https://example.com")!)
  }
}
