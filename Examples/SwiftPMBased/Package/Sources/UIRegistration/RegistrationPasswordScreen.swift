import CommonUI
import SwiftUI

public struct RegistrationPasswordScreen: View {
  private let viewModel: RegistrationViewModel
  private let onLoggedIn: () -> Void

  public init(
    viewModel: RegistrationViewModel,
    onLoggedIn: @escaping () -> Void
  ) {
    self.viewModel = viewModel
    self.onLoggedIn = onLoggedIn
  }

  public var body: some View {
    RegistrationPasswordContent(
      password: viewModel.password,
      isRegisterButtonEnabled: viewModel.isRegisterButtonEnabled,
      isRegisterButtonLoading: viewModel.isRegistering,
      onPasswordChanged: { newValue in
        viewModel.onPasswordChanged(newValue)
      },
      onRegisterButtonTapped: {
        Task {
          await viewModel.onRegisterButtonTapped()
        }
      }
    )
    .alert(
      "",
      isPresented: .init(
        get: {
          viewModel.alertKind != nil
        },
        set: { newValue in
          if newValue == false {
            viewModel.onAlertDismissed()
          }
        }
      ),
      presenting: viewModel.alertKind,
      actions: { alertKind in
        switch alertKind {
        case .registrationFailure:
          Button("OK", action: {})
        }
      },
      message: { alertKind in
        switch alertKind {
        case .registrationFailure:
          Text("Registration Failure")
        }
      }
    )
    .onChange(of: viewModel.completedEvent) { _, newValue in
      if newValue != nil {
        onLoggedIn()
        viewModel.onCompletedEventConsumed()
      }
    }
  }
}

struct RegistrationPasswordContent: View {
  let password: String
  let isRegisterButtonEnabled: Bool
  let isRegisterButtonLoading: Bool
  let onPasswordChanged: (String) -> Void
  let onRegisterButtonTapped: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        SecureField(
          "Password",
          text: .init(
            get: {
              password
            },
            set: { newValue in
              onPasswordChanged(newValue)
            }
          )
        )
        .textFieldStyle(.roundedBorder)
        .padding(16)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      Button(
        action: onRegisterButtonTapped,
        label: {
          if isRegisterButtonLoading {
            ProgressView()
              .frame(maxWidth: .infinity)
          } else {
            Text("Register")
              .frame(maxWidth: .infinity)
          }
        }
      )
      .buttonStyle(.rounded)
      .disabled(!isRegisterButtonEnabled)
      .padding(16)
    }
    .navigationTitle("Password")
  }
}

#Preview {
  NavigationStack {
    RegistrationPasswordContent(
      password: "",
      isRegisterButtonEnabled: true,
      isRegisterButtonLoading: false,
      onPasswordChanged: { _ in },
      onRegisterButtonTapped: {}
    )
  }
}
