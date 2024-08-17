import SwiftGraph
import SwordFoundation

struct BindingGraphFactory {
  private let subcomponentsByParent: [ComponentName: [Component]]
  private let dependenciesByComponentName: [ComponentName: [Dependency]]
  private let modulesByComponentName: [ComponentName: [Module]]

  init(
    subcomponentsByParent: [ComponentName: [Component]],
    dependenciesByComponentName: [ComponentName: [Dependency]],
    modulesByComponentName: [ComponentName: [Module]]
  ) {
    self.subcomponentsByParent = subcomponentsByParent
    self.dependenciesByComponentName = dependenciesByComponentName
    self.modulesByComponentName = modulesByComponentName
  }

  func makeBindingGraph(rootComponent: Component) -> BindingGraph {
    let network = UnweightedGraph<BindingGraph.Node>()
    visit(component: rootComponent, network: network)
    return BindingGraph(rootComponent: rootComponent, network: network)
  }

  private func visit(
    component: Component,
    network: UnweightedGraph<BindingGraph.Node>,
    parentBindingsByKey: [Key: [Binding]]? = nil
  ) {
    var bindingsByKey = [Key: [Binding]]()

    for componentArgument in component.arguments {
      bindingsByKey[componentArgument.key, default: []].append(Binding(componentArgument: componentArgument))
    }

    let dependencies = dependenciesByComponentName[component.name] ?? []
    for dependency in dependencies {
      bindingsByKey[dependency.key, default: []].append(Binding(dependency: dependency))
    }

    let providers = (modulesByComponentName[component.name] ?? []).flatMap(\.providers)
    for provider in providers {
      bindingsByKey[provider.key, default: []].append(Binding(provider: provider))
    }

    let bindings = bindingsByKey.values.flatMap { $0 }
    let componentIndex = network.addVertex(.component(component))
    addBindings(
      bindings,
      componentIndex: componentIndex,
      network: network
    )

    let reachableBindingsByKey = bindingsByKey.merging(parentBindingsByKey ?? [Key: [Binding]](), uniquingKeysWith: +)
    resolveBindings(
      bindings,
      network: network,
      reachableBindingsByKey: reachableBindingsByKey
    )

    for subcomponent in (subcomponentsByParent[component.name] ?? []) {
      visit(
        component: subcomponent,
        network: network,
        parentBindingsByKey: reachableBindingsByKey
      )
      if let subcomponentIndex = network.indexOfVertex(.component(subcomponent)) {
        network.addEdgeIfNotExist(fromIndex: componentIndex, toIndex: subcomponentIndex, directed: true)
      }
    }
  }

  private func addBindings(
    _ bindings: [Binding],
    componentIndex: Int,
    network: UnweightedGraph<BindingGraph.Node>
  ) {
    for binding in bindings {
      let bindingNode: BindingGraph.Node = .binding(binding)
      let bindingIndex = network.addVertex(bindingNode)
      network.addEdge(fromIndex: componentIndex, toIndex: bindingIndex, directed: true)
    }
  }

  private func resolveBindings(
    _ bindings: [Binding],
    network: UnweightedGraph<BindingGraph.Node>,
    reachableBindingsByKey: [Key: [Binding]]
  ) {
    for binding in bindings {
      guard let bindingIndex = network.indexOfVertex(.binding(binding)) else { continue }

      for dependencyRequest in binding.dependencyRequests {
        let resolvedBindings = reachableBindingsByKey[dependencyRequest.key] ?? []
        if resolvedBindings.isEmpty {
          let missingBindingNode: BindingGraph.Node = .missingBinding(dependencyRequest)
          let missingBindingIndex = network.addVertex(missingBindingNode)
          network.addEdgeIfNotExist(fromIndex: bindingIndex, toIndex: missingBindingIndex, directed: true)
        } else {
          for resolvedBinding in resolvedBindings {
            let resolvedBindingNode: BindingGraph.Node = .binding(resolvedBinding)
            if let resolvedBindingIndex = network.indexOfVertex(resolvedBindingNode) {
              network.addEdgeIfNotExist(fromIndex: bindingIndex, toIndex: resolvedBindingIndex, directed: true)
            }
          }
        }
      }
    }
  }
}

private extension UnweightedGraph<BindingGraph.Node> {
  func addEdgeIfNotExist(fromIndex: Int, toIndex: Int, directed: Bool) {
    let edge = UnweightedEdge(u: fromIndex, v: toIndex, directed: directed)
    if !edgeExists(edge) {
      addEdge(edge, directed: true)
    }
  }
}
