import Foundation
import SwiftSyntax
import SwordFoundation

package struct ComponentArgument: Hashable, Codable {
  package let key: Key
  package let type: Type
  package let location: SourceLocation

  package init(
    argument: String,
    location: SourceLocation
  ) {
    let type = Type(value: argument)
    self.key = Key(type: type)
    self.type = type
    self.location = location
  }

  package init?(
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
