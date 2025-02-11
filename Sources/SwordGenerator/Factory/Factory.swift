protocol Factory {
  associatedtype T
  func make() async -> FactoryResult<T>
}

enum FactoryResult<Success: Sendable>: Sendable {
  case success(Success)
  case failure([Report])

  var reports: [Report] {
    switch self {
    case .success: []
    case .failure(let reports): reports
    }
  }
}
