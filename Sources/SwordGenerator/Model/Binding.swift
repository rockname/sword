import Foundation
import SwiftSyntax
import SwordComponentArgument
import SwordFoundation

struct Binding: Hashable, Codable {
  enum Kind: Hashable, Codable {
    case registration(
      parameters: [Parameter],
      calledExpression: String,
      hasMainActor: Bool,
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
    case .registration(let parameters, _, _, _):
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
      hasMainActor: dependency.hasMainActor,
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
      hasMainActor: provider.hasMainActor,
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
