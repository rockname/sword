import Foundation
import SwiftSyntax
import SwordFoundation

struct ProviderDescriptor: Hashable {
  let name: String
  let isStaticFunction: Bool
  let returnType: Type?
  let parameters: [Parameter]
  let hasMainActor: Bool
  let scope: Scope?
  let location: SourceLocation
}
