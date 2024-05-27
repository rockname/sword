import Foundation
import SwiftSyntax
import SwordFoundation

struct Parameter {
  let key: Key
  let type: Type
  let name: String
  let isAssisted: Bool
  let location: SourceLocation
}
