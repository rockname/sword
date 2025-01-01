import ComponentApp
import DataRepository
import Foundation
import SwiftUI
import UILaunch

struct RootNavigation: View {
  let component: AppComponent

  let navigationModel: RootNavigationModel

  var body: some View {
    switch navigationModel.navigationState {
    case .launching:
      LaunchScreen(
        onLaunched: {
          Task {
            await navigationModel.onLaunched()
          }
        }
      )
    case .notLoggedIn:
      OnboardingNavigation(
        component: component,
        onLoggedIn: navigationModel.onLoggedIn
      )
    case .loggedIn:
      HomeNavigation(
        component: component.makeUserComponent(),
        onLoggedOut: navigationModel.onLoggedOut
      )
    }
  }
}
