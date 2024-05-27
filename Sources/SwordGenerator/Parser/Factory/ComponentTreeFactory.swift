import Foundation

final class ComponentTreeFactory {
  private let subcomponentsByParent: [ComponentName: [ComponentNode]]
  private let dependenciesByComponentName: [ComponentName: [Dependency]]
  private let modulesByComponentName: [ComponentName: [Module]]

  init(
    subcomponentsByParent: [ComponentName: [ComponentNode]],
    dependenciesByComponentName: [ComponentName: [Dependency]],
    modulesByComponentName: [ComponentName: [Module]]
  ) {
    self.subcomponentsByParent = subcomponentsByParent
    self.dependenciesByComponentName = dependenciesByComponentName
    self.modulesByComponentName = modulesByComponentName
  }

  func makeComponentTree(componentNode: ComponentNode) -> ComponentTree {
    let registrations: [Registration] =
      (dependenciesByComponentName[componentNode.name] ?? []).map(Registration.init(dependency:))
      + (modulesByComponentName[componentNode.name] ?? []).flatMap { module in
        module.providers.map { Registration(moduleName: module.name, provider: $0) }
      }

    let subcomponents = subcomponentsByParent[componentNode.name] ?? []
    let subcomponentTrees = subcomponents.map { subcomponent in
      makeComponentTree(componentNode: subcomponent)
    }

    return ComponentTree(
      componentNode: componentNode,
      registrations: registrations,
      subcomponentTrees: subcomponentTrees
    )
  }
}
