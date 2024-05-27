import Foundation
import SwiftSyntax
import SwordFoundation

struct Provider {
  let name: String
  let type: Type
  let parameters: [Parameter]
  let scope: Scope?
  let location: SourceLocation
}
