import SwiftGraph
import SwiftSyntax
import SwordFoundation

final class BindingGraph {
  enum Node: Equatable, Codable {
    case component(Component)
    case binding(Binding)
    case missingBinding(DependencyRequest)

    static func == (lhs: Node, rhs: Node) -> Bool {
      switch (lhs, rhs) {
      case (.component(let lhsComponent), .component(let rhsComponent)):
        lhsComponent.name == rhsComponent.name
      case (.binding(let lhsBinding), .binding(let rhsBinding)):
        lhsBinding.key == rhsBinding.key
      case (.missingBinding(let lhsDependencyRequest), .missingBinding(let rhsDependencyRequest)):
        lhsDependencyRequest.key == rhsDependencyRequest.key
      default:
        false
      }
    }
  }

  var nodes: [Node] {
    network.vertices
  }

  var isDAG: Bool {
    network.isDAG
  }

  var cycles: [[Node]] {
    network.detectCycles()
  }

  let rootComponent: Component
  private let network: UnweightedGraph<Node>

  init(
    rootComponent: Component,
    network: UnweightedGraph<Node>
  ) {
    self.network = network
    self.rootComponent = rootComponent
  }

  func bindings(for component: Component) -> [Binding] {
    (network.neighborsForVertex(.component(component)) ?? []).compactMap { node in
      switch node {
      case .binding(let binding):
        binding
      case .component, .missingBinding:
        nil
      }
    }
  }

  func requiredBindings(for binding: Binding) -> [Binding] {
    let bindingIndex = network.indexOfVertex(.binding(binding))
    let neighborEdges = network.edgesForVertex(.binding(binding)) ?? []
    let destinationNodes =
      neighborEdges
      .filter { neighborEdge in
        let origin = neighborEdge.u
        return origin == bindingIndex
      }
      .map { neighborEdge in
        let destination = neighborEdge.v
        return network.vertexAtIndex(destination)
      }
    return
      destinationNodes
      .compactMap { destinationNode in
        switch destinationNode {
        case .binding(let binding):
          binding
        case .component, .missingBinding:
          nil
        }
      }
  }

  func subcomponents(for component: Component) -> [Component] {
    (network.neighborsForVertex(.component(component)) ?? []).compactMap { node in
      if case .component(let subcomponent) = node,
        subcomponent.parentComponentName == component.name
      {
        subcomponent
      } else {
        nil
      }
    }
  }
}
