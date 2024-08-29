import SwiftSyntax
import SwordFoundation

struct Dependency {
  let key: Key
  let type: Type
  let interface: Interface?
  let initializer: Initializer
  let hasMainActor: Bool
  let scope: Scope?
  let location: SourceLocation

  init(
    type: Type,
    interface: Interface?,
    initializer: Initializer,
    hasMainActor: Bool,
    scope: Scope?,
    location: SourceLocation
  ) {
    self.key = Key(type: interface?.asType() ?? type)
    self.type = type
    self.interface = interface
    self.initializer = initializer
    self.hasMainActor = hasMainActor
    self.scope = scope
    self.location = location
  }
}
