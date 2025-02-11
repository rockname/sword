import os

enum Logging {
  static let logger = Logger(subsystem: "com.rockname.sword", category: "Generator")
  static let signposter = OSSignposter(logger: logger)

  static func recordInterval<R>(name: StaticString, body: () throws -> R) rethrows -> R {
    let signpostID = signposter.makeSignpostID()
    let state = signposter.beginInterval(name, id: signpostID)
    let result = try body()
    signposter.endInterval(name, state)
    return result
  }

  static func recordInterval<R>(name: StaticString, body: () async throws -> R) async rethrows -> R {
    let signpostID = signposter.makeSignpostID()
    let state = signposter.beginInterval(name, id: signpostID)
    let result = try await body()
    signposter.endInterval(name, state)
    return result
  }
}
