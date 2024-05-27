import SwiftUI

public struct LaunchScreen: View {
  private let onLaunched: () -> Void

  public init(onLaunched: @escaping () -> Void) {
    self.onLaunched = onLaunched
  }

  public var body: some View {
    ZStack {
      Text("🗡️")
        .font(.largeTitle)
    }
    .task {
      try? await Task.sleep(for: .nanoseconds(500))
      onLaunched()
    }
  }
}
