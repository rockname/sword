import SwiftSyntax
import SwordComponentArgument

struct SubcomponentDescriptor {
  let name: ComponentName
  let arguments: [ComponentArgument]
  let parentName: String
  let location: SourceLocation
}
