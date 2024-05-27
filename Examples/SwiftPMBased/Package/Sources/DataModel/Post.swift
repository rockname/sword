import Foundation

public struct Post {
  public struct ID: Hashable {
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
