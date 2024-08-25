import Foundation
import SwiftSyntax
import SwordComponentArgument
import SwordFoundation

struct Binding: Codable {
  enum Kind: Codable {
    case registration(
      parameters: [Parameter],
      calledExpression: String,
      scope: Scope?
    )
    case componentArgument
  }

  let key: Key
  let type: Type
  let kind: Kind
  let location: SourceLocation

  var dependencyRequests: [DependencyRequest] {
    switch kind {
    case .registration(let parameters, _, _):
      parameters
        .filter { !$0.isAssisted }
        .map {
          DependencyRequest(
            key: $0.key,
            type: $0.type,
            location: $0.location
          )
        }
    case .componentArgument:
      []
    }
  }

  init(componentArgument: ComponentArgument) {
    self.key = componentArgument.key
    self.type = componentArgument.type
    self.kind = .componentArgument
    self.location = componentArgument.location
  }

  init(dependency: Dependency) {
    self.key = dependency.key
    self.type = dependency.interface?.asType() ?? dependency.type
    self.kind = .registration(
      parameters: dependency.initializer.parameters,
      calledExpression: dependency.type.value,
      scope: dependency.scope
    )
    self.location = dependency.location
  }

  init(provider: Provider) {
    self.key = provider.key
    self.type = provider.type
    self.kind = .registration(
      parameters: provider.parameters,
      calledExpression: "\(provider.moduleName).\(provider.name)",
      scope: provider.scope
    )
    self.location = provider.location
  }
}

struct DependencyRequest: Hashable, Codable {
  let key: Key
  let type: Type
  let location: SourceLocation
}
