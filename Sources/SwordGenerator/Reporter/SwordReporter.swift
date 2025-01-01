import Foundation

package struct SwordReporter {
  enum Severity: String {
    case error
    case warning
  }

  private let fileUpdater: FileHandle

  package init(fileUpdater: FileHandle) {
    self.fileUpdater = fileUpdater
  }

  func send(_ report: Report) {
    let place =
      if let location = report.location {
        "\(location.file):\(location.line):\(location.column): "
      } else {
        ""
      }
    fileUpdater.write(
      Data(("\(place)" + "\(report.severity.rawValue): \(report.message)" + "\n").utf8)
    )
  }
}
