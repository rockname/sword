import SwiftSyntax
import SwordComponentArgument

struct RootComponentDescriptor {
  let name: ComponentName
  let arguments: [ComponentArgument]
  let location: SourceLocation
}
