import ComponentApp
import SwiftUI
import UIOnboarding
import UIRegistration

enum OnboardingNavigationRoute: Hashable {
  case registrationUsername
  case registrationPassword
}

struct OnboardingNavigation: View {
  @State private var navigationPath = [OnboardingNavigationRoute]()

  let component: AppComponent
  let onLoggedIn: () -> Void

  var body: some View {
    NavigationStack(path: $navigationPath) {
      OnboardingScreen(
        onRegistrationButtonTapped: {
          navigationPath.append(.registrationUsername)
        }
      )
      .navigationDestination(for: OnboardingNavigationRoute.self) { route in
        switch route {
        case .registrationUsername:
          RegistrationUsernameScreen(
            viewModel: component.registrationViewModel,
            onNextButtonTapped: {
              navigationPath.append(.registrationPassword)
            }
          )
        case .registrationPassword:
          RegistrationPasswordScreen(
            viewModel: component.registrationViewModel,
            onLoggedIn: onLoggedIn
          )
        }
      }
    }
  }
}
