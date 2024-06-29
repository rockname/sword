import AudioRecorder
import ComponentApp
import Observation
import SwiftUI
import Sword

struct VoiceMemoUIState {
  enum RecorderPermission {
    case allowed
    case denied
    case undetermined
  }

  var recordedVoiceMemos: [VoiceMemo] = []
  var recorderPermission: RecorderPermission = .undetermined
  var elapsedTime: TimeInterval = .zero
  var isRecording: Bool = false
  var isStopping: Bool = false

  var displayedElapsedTime: String? {
    dateComponentsFormatter.string(from: .init(second: Int(elapsedTime)))
  }

  private let dateComponentsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
  }()
}

@Observable
@Dependency(registeredTo: AppComponent.self)
final class VoiceMemoViewModel {
  @MainActor
  private(set) var uiState: VoiceMemoUIState = .init()

  private var timerTask: Task<Void, Error>?

  private let audioRecorder: AudioRecorder
  private let timerSequence: any AsyncSequence
  private let temporaryDirectory: URL
  private let uuidGenerator: () -> String
  private let currentDateGenerator: () -> Date

  @Injected
  init(
    audioRecorder: AudioRecorder,
    @Assisted timerSequence: any AsyncSequence,
    @Assisted temporaryDirectory: URL,
    @Assisted uuidGenerator: @escaping () -> String,
    @Assisted currentDateGenerator: @escaping () -> Date
  ) {
    self.audioRecorder = audioRecorder
    self.timerSequence = timerSequence
    self.temporaryDirectory = temporaryDirectory
    self.uuidGenerator = uuidGenerator
    self.currentDateGenerator = currentDateGenerator
  }

  @MainActor
  func onRecordButtonTapped() async {
    if uiState.isRecording {
      stopRecording()
    } else {
      switch uiState.recorderPermission {
      case .undetermined:
        let isAllowed = await audioRecorder.requestPermission()
        if isAllowed {
          uiState.recorderPermission = .allowed
          await startRecording()
        } else {
          uiState.recorderPermission = .denied
        }
      case .denied:
        break
      case .allowed:
        await startRecording()
      }
    }
  }

  @MainActor
  private func startRecording() async {
    uiState.isRecording = true

    do {
      timerTask = Task {
        for try await _ in timerSequence {
          if Task.isCancelled { break }

          await MainActor.run { [weak self] in
            self?.uiState.elapsedTime += 1
          }
        }
      }

      let currentDate = currentDateGenerator()
      let url =
        temporaryDirectory
        .appendingPathComponent(uuidGenerator())
        .appendingPathExtension("m4a")
      let result = try await audioRecorder.record(url: url)
      if result == true {
        uiState.recordedVoiceMemos.append(
          VoiceMemo(
            url: url,
            date: currentDate,
            duration: TimeInterval(uiState.elapsedTime)
          )
        )
      } else {

      }
    } catch {

    }

    uiState.isRecording = false
    uiState.isStopping = false
    uiState.elapsedTime = .zero
  }

  @MainActor
  private func stopRecording() {
    guard
      uiState.isStopping == false,
      let currentTime = audioRecorder.currentTime
    else {
      return
    }

    uiState.isStopping = true
    uiState.elapsedTime = currentTime
    timerTask?.cancel()
    audioRecorder.stop()
  }
}
