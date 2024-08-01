import SwordFoundation

extension Scope {
  var methodName: String {
    switch self {
    case .single:
      "withSingle"
    case .weakReference:
      "withWeakReference"
    }
  }
}
