import Foundation

public struct Type: Hashable, Codable {
  public let value: String

  public init(value: String) {
    self.value = value
  }
}
