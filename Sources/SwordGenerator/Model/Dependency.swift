import Foundation
import SwiftSyntax
import SwordFoundation

struct Dependency {
  let type: Type
  let interface: Interface?
  let initializer: Initializer
  let scope: Scope?
  let location: SourceLocation
}
