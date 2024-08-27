import SwiftSyntax
import SwordFoundation

struct Dependency {
  let key: Key
  let type: Type
  let interface: Interface?
  let initializer: Initializer
  let hasMainActorAttribute: Bool
  let scope: Scope?
  let location: SourceLocation

  init(
    type: Type,
    interface: Interface?,
    initializer: Initializer,
    hasMainActorAttribute: Bool,
    scope: Scope?,
    location: SourceLocation
  ) {
    self.key = Key(type: interface?.asType() ?? type)
    self.type = type
    self.interface = interface
    self.initializer = initializer
    self.hasMainActorAttribute = hasMainActorAttribute
    self.scope = scope
    self.location = location
  }
}
