import Foundation
import SwordFoundation

final class ComponentTree {
  let componentNode: ComponentNode
  let registrations: [Registration]
  let subcomponentTrees: [ComponentTree]

  var bindingsByKey: [Key: [Binding]] {
    var result = [Key: [Binding]]()
    for argument in componentNode.arguments {
      result[Key(type: argument.type), default: []].append(
        Binding(componentArgument: argument)
      )
    }
    for registration in registrations {
      result[registration.key, default: []].append(
        Binding(registration: registration)
      )
    }
    return result
  }

  init(
    componentNode: ComponentNode,
    registrations: [Registration],
    subcomponentTrees: [ComponentTree]
  ) {
    self.componentNode = componentNode
    self.registrations = registrations
    self.subcomponentTrees = subcomponentTrees
  }
}
