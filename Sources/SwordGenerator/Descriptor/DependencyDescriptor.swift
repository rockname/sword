import Foundation
import SwiftSyntax
import SwordFoundation

struct DependencyDescriptor {
  let componentName: ComponentName
  let type: Type
  let interface: Interface?
  let injectedInitializers: [Initializer]
  let hasMainActor: Bool
  let scope: Scope?
  let isReferenceType: Bool
  let location: SourceLocation
}
