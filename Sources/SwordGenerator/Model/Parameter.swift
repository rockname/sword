import Foundation
import SwiftSyntax
import SwordFoundation

struct Parameter: Hashable, Codable {
  let key: Key
  let type: Type
  let name: String
  let isAssisted: Bool
  let location: SourceLocation
}
