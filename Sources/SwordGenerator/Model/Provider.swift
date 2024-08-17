import Foundation
import SwiftSyntax
import SwordFoundation

struct Provider {
  let moduleName: String
  let name: String
  let key: Key
  let type: Type
  let parameters: [Parameter]
  let scope: Scope?
  let location: SourceLocation

  init(
    moduleName: String,
    name: String,
    type: Type,
    parameters: [Parameter],
    scope: Scope?,
    location: SourceLocation
  ) {
    self.moduleName = moduleName
    self.name = name
    self.key = Key(type: type)
    self.type = type
    self.parameters = parameters
    self.scope = scope
    self.location = location
  }
}
