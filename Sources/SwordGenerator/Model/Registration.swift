import Foundation
import SwiftSyntax
import SwordFoundation

struct Registration {
  let key: Key
  let type: Type
  let calledExpressionName: String
  let parameters: [Parameter]
  let scope: Scope?
  let location: SourceLocation

  init(dependency: Dependency) {
    let registrationType = dependency.interface?.asType() ?? dependency.type
    self.key = Key(type: registrationType)
    self.type = registrationType
    self.parameters = dependency.initializer.parameters
    self.calledExpressionName = dependency.type.value
    self.scope = dependency.scope
    self.location = dependency.location
  }

  init(moduleName: String, provider: Provider) {
    self.key = Key(type: provider.type)
    self.type = provider.type
    self.parameters = provider.parameters
    self.calledExpressionName = "\(moduleName).\(provider.name)"
    self.scope = provider.scope
    self.location = provider.location
  }
}
