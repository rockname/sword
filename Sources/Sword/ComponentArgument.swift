import Foundation

public struct ComponentArgument {
  private let type: Any.Type

  public init(_ type: Any.Type) {
    self.type = type
  }
}
