import AVFoundation
import ComponentApp
import Sword

public protocol AudioRecorder {
  var currentTime: TimeInterval? { get }

  func requestPermission() async -> Bool
  func record(url: URL) async throws -> Bool
  func stop()
}

@Dependency(
  registeredTo: AppComponent.self,
  boundTo: AudioRecorder.self
)
public final class DefaultAudioRecorder: AudioRecorder {
  private var recorder: AVAudioRecorder?

  private var delegate: Delegate?

  @Injected
  public init() {
  }

  public var currentTime: TimeInterval? {
    guard
      let recorder, recorder.isRecording
    else { return nil }

    return recorder.currentTime
  }

  public func requestPermission() async -> Bool {
    await AVAudioApplication.requestRecordPermission()
  }

  public func record(url: URL) async throws -> Bool {
    stop()

    let stream = AsyncThrowingStream<Bool, Error> { continuation in
      do {
        delegate = Delegate(
          onRecordingFinished: { flag in
            continuation.yield(flag)
            continuation.finish()
            try? AVAudioSession.sharedInstance().setActive(false)
          },
          onEncodeErrorOccur: { error in
            continuation.finish(throwing: error)
            try? AVAudioSession.sharedInstance().setActive(false)
          }
        )
        let recorder = try AVAudioRecorder(
          url: url,
          settings: [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
          ]
        )
        self.recorder = recorder
        recorder.delegate = delegate

        continuation.onTermination = { _ in
          recorder.stop()
        }

        try AVAudioSession.sharedInstance().setCategory(
          .playAndRecord,
          mode: .default,
          options: .defaultToSpeaker
        )
        try AVAudioSession.sharedInstance().setActive(true)
        recorder.record()
      } catch {
        continuation.finish(throwing: error)
      }
    }

    for try await onFinish in stream {
      return onFinish
    }
    throw CancellationError()
  }

  public func stop() {
    recorder?.stop()
    try? AVAudioSession.sharedInstance().setActive(false)
  }

  private final class Delegate: NSObject, AVAudioRecorderDelegate {
    let onRecordingFinished: (Bool) -> Void
    let onEncodeErrorOccur: (Error?) -> Void

    init(
      onRecordingFinished: @escaping (Bool) -> Void,
      onEncodeErrorOccur: @escaping (Error?) -> Void
    ) {
      self.onRecordingFinished = onRecordingFinished
      self.onEncodeErrorOccur = onEncodeErrorOccur
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
      self.onRecordingFinished(flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
      self.onEncodeErrorOccur(error)
    }
  }
}
