import Foundation
import SwiftSyntax
import SwordFoundation

struct DependencyDescriptor {
  let type: Type
  let interface: Interface?
  let injectedInitializers: [Initializer]
  let hasMainActor: Bool
  let scope: Scope?
  let isClass: Bool
  let location: SourceLocation
}
