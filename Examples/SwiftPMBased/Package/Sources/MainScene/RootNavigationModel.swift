import DataRepository
import Observation
import SwiftUI

enum RootNavigationState {
  case launching
  case notLoggedIn
  case loggedIn
}

@MainActor
@Observable
final class RootNavigationModel {
  private(set) var navigationState: RootNavigationState = .launching

  private let userRepository: UserRepository

  init(userRepository: UserRepository) {
    self.userRepository = userRepository
  }

  func onLaunched() async {
    if await userRepository.isUserLoggedIn {
      withAnimation {
        navigationState = .loggedIn
      }
    } else {
      withAnimation {
        navigationState = .notLoggedIn
      }
    }
  }

  func onLoggedIn() {
    withAnimation {
      navigationState = .loggedIn
    }
  }

  func onLoggedOut() {
    withAnimation {
      navigationState = .notLoggedIn
    }
  }
}
