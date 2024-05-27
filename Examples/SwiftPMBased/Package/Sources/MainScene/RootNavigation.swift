import ComponentApp
import DataRepository
import Foundation
import SwiftUI
import UILaunch

enum RootNavigationState {
  case launching
  case notLoggedIn
  case loggedIn
}

struct RootNavigation: View {
  @State private var navigationState: RootNavigationState = .launching

  let component: AppComponent
  var userRepository: UserRepository {
    component.userRepository
  }

  var body: some View {
    switch navigationState {
    case .launching:
      LaunchScreen(
        onLaunched: {
          withAnimation {
            if userRepository.isUserLoggedIn {
              navigationState = .loggedIn
            } else {
              navigationState = .notLoggedIn
            }
          }
        }
      )
    case .notLoggedIn:
      OnboardingNavigation(
        component: component.makeRegistrationComponent(),
        onLoggedIn: {
          withAnimation {
            navigationState = .loggedIn
          }
        }
      )
    case .loggedIn:
      HomeNavigation(
        component: component.makeUserComponent(),
        onLoggedIn: {
          withAnimation {
            navigationState = .notLoggedIn
          }
        }
      )
    }
  }
}
