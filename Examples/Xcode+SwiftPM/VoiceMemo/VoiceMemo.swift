import Foundation

struct VoiceMemo: Equatable, Identifiable {
  let url: URL
  let date: Date
  let duration: TimeInterval
  let title = ""

  var id: String { url.absoluteString }
}
