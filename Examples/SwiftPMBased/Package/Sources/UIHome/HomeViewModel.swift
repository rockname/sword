import ComponentUser
import DataModel
import DataRepository
import Observation
import Sword

enum HomeUIState {
  case initial
  case loading
  case success([Post])
  case error
}

@Dependency(registeredTo: UserComponent.self)
@Observable
@MainActor
public final class HomeViewModel {
  private(set) var uiState: HomeUIState = .initial

  private let homeTimelineRepository: HomeTimelineRepository

  @Injected
  public init(homeTimelineRepository: HomeTimelineRepository) {
    self.homeTimelineRepository = homeTimelineRepository
  }

  func onAppear() async {
    guard case .initial = uiState else { return }

    await loadInitialTimeline()
  }

  private func loadInitialTimeline() async {
    uiState = .loading
    do {
      let posts = try await homeTimelineRepository.fetchInitialTimeline()
      uiState = .success(posts)
    } catch {
      uiState = .error
    }
  }
}
