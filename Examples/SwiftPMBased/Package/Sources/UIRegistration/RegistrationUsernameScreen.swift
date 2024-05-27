import CommonUI
import SwiftUI

public struct RegistrationUsernameScreen: View {
  private let viewModel: RegistrationViewModel
  private let onNextButtonTapped: () -> Void

  public init(
    viewModel: RegistrationViewModel,
    onNextButtonTapped: @escaping () -> Void
  ) {
    self.viewModel = viewModel
    self.onNextButtonTapped = onNextButtonTapped
  }

  public var body: some View {
    RegistrationUsernameContent(
      username: viewModel.username,
      isNextButtonEnabled: viewModel.isNextButtonEnabled,
      onUsernameChanged: { newValue in
        viewModel.onUsernameChanged(newValue)
      },
      onNextButtonTapped: onNextButtonTapped
    )
  }
}

struct RegistrationUsernameContent: View {
  let username: String
  let isNextButtonEnabled: Bool
  let onUsernameChanged: (String) -> Void
  let onNextButtonTapped: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        TextField(
          "Username",
          text: .init(
            get: {
              username
            },
            set: { newValue in
              onUsernameChanged(newValue)
            }
          )
        )
        .textFieldStyle(.roundedBorder)
        .padding(16)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      Button(
        action: onNextButtonTapped,
        label: {
          Text("Next")
            .frame(maxWidth: .infinity)
        }
      )
      .buttonStyle(.rounded)
      .disabled(!isNextButtonEnabled)
      .padding(16)
    }
    .navigationTitle("Username")
  }
}

#Preview {
  NavigationStack {
    RegistrationUsernameContent(
      username: "",
      isNextButtonEnabled: true,
      onUsernameChanged: { _ in },
      onNextButtonTapped: {}
    )
  }
}
