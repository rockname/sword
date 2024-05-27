import Foundation
import SwiftSyntax

struct Report {
  enum Severity: String {
    case error
    case warning
  }

  let message: String
  let severity: Severity
  let location: SourceLocation?

  init(
    message: String,
    severity: Severity,
    location: SourceLocation? = nil
  ) {
    self.message = message
    self.severity = severity
    self.location = location
  }
}
