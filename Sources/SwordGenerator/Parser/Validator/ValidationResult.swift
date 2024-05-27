import Foundation

enum ValidationResult<T> {
  case valid(T)
  case invalid([Report])

  var reports: [Report] {
    switch self {
    case .valid:
      []
    case .invalid(let reports):
      reports
    }
  }
}
