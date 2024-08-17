import SwiftSyntax
import SwordComponentArgument

struct Component: Codable {
  let name: ComponentName
  let arguments: [ComponentArgument]
  let parentComponentName: ComponentName?
  let location: SourceLocation
}
