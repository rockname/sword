import CommonUI
import SwiftUI

public struct OnboardingScreen: View {
  let onRegistrationButtonTapped: () -> Void

  public init(
    onRegistrationButtonTapped: @escaping () -> Void
  ) {
    self.onRegistrationButtonTapped = onRegistrationButtonTapped
  }

  public var body: some View {
    VStack(spacing: 0) {
      ZStack {
        VStack(spacing: 16) {
          Text("🗡️")
            .font(.largeTitle)
          Text("SNS Example")
            .font(.body)
            .multilineTextAlignment(.center)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      Button(
        action: onRegistrationButtonTapped,
        label: {
          Text("Start")
            .frame(maxWidth: .infinity)
        }
      )
      .buttonStyle(.rounded)
    }
    .padding(16)
  }
}

#Preview {
  OnboardingScreen(
    onRegistrationButtonTapped: {}
  )
}
