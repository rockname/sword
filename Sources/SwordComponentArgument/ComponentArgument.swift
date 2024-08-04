import Foundation
import SwiftSyntax
import SwordFoundation

public struct ComponentArgument: Hashable {
  public let key: Key
  public let type: Type
  public let location: SourceLocation

  public init(
    argument: String,
    location: SourceLocation
  ) {
    let type = Type(value: argument)
    self.key = Key(type: type)
    self.type = type
    self.location = location
  }

  public init?(
    element: LabeledExprListSyntax.Element,
    location: SourceLocation
  ) {
    guard
      let argument = element.expression
        .as(MemberAccessExprSyntax.self)?.base
    else { return nil }

    self.init(
      argument: "\(argument)",
      location: location
    )
  }
}
