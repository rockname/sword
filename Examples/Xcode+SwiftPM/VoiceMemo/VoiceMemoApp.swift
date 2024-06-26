import AsyncAlgorithms
import AudioRecorder
import ComponentApp
import SwiftUI

@main
struct VoiceMemoApp: App {
  let component = AppComponent()
  var body: some Scene {
    WindowGroup {
      VoiceMemoScreen(
        viewModel: component.voiceMemoViewModel(
          AsyncTimerSequence(interval: .seconds(1), clock: .continuous),
          URL(fileURLWithPath: NSTemporaryDirectory()),
          { UUID().uuidString },
          { Date.now }
        )
      )
    }
  }
}
