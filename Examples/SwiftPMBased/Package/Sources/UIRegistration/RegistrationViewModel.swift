import ComponentApp
import DataRepository
import Foundation
import Observation
import Sword

struct RegistrationCompletedEvent: Equatable {
}

enum RegistrationAlertKind {
  case registrationFailure
}

@Dependency(
  registeredTo: AppComponent.self,
  scopedWith: .weakReference
)
@Observable
public final class RegistrationViewModel {
  private(set) var username = ""
  private(set) var password = ""
  private(set) var isRegistering = false
  @MainActor
  private(set) var alertKind: RegistrationAlertKind?
  @MainActor
  private(set) var completedEvent: RegistrationCompletedEvent?

  var isNextButtonEnabled: Bool {
    !username.isEmpty
  }

  var isRegisterButtonEnabled: Bool {
    !password.isEmpty
  }

  private let userRepository: UserRepository

  @Injected
  public init(userRepository: UserRepository) {
    self.userRepository = userRepository
  }

  func onUsernameChanged(_ text: String) {
    username = text
  }

  func onPasswordChanged(_ text: String) {
    password = text
  }

  @MainActor
  func onRegisterButtonTapped() async {
    isRegistering = true
    do {
      try await userRepository.registerUser(username: username, password: password)
      completedEvent = .init()
    } catch {
      alertKind = .registrationFailure
    }
    isRegistering = false
  }

  @MainActor
  func onAlertDismissed() {
    alertKind = nil
  }

  @MainActor
  func onCompletedEventConsumed() {
    completedEvent = nil
  }
}
