import Foundation

enum Scope: String {
  case single

  var methodName: String {
    switch self {
    case .single:
      "withSingle"
    }
  }
}
