import Foundation

public struct Post: Sendable {
  public struct ID: Hashable, Sendable {
    public let value: String

    public init(value: String) {
      self.value = value
    }
  }

  public let id: ID
  public let username: String
  public let content: String

  public init(
    id: ID,
    username: String,
    content: String
  ) {
    self.id = id
    self.username = username
    self.content = content
  }
}
