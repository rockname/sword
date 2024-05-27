import Foundation
import SwordComponentArgument

struct ComponentNode {
  let name: ComponentName
  let arguments: [ComponentArgument]

  init(
    name: ComponentName,
    arguments: [ComponentArgument]
  ) {
    self.name = name
    self.arguments = arguments
  }
}
