import Foundation
import SwiftGraph
import SwiftSyntax
import SwordFoundation

struct BindingGraphFactory: Factory {
  private struct ResolvedBinding {
    enum DependencyRequestResult {
      case missing(dependencyRequest: DependencyRequest)
      case resolved(index: Int)
    }

    let bindingIndex: Int
    let dependencyRequestResults: [DependencyRequestResult]
  }

  let componentTree: ComponentTree
  let dependenciesByComponentName: [ComponentName: [Dependency]]
  let modulesByComponentName: [ComponentName: [Module]]

  init(
    componentTree: ComponentTree,
    dependencies: [Dependency],
    modules: [Module]
  ) {
    self.componentTree = componentTree
    var dependenciesByComponentName = [ComponentName: [Dependency]]()
    for dependency in dependencies {
      dependenciesByComponentName[
        dependency.componentName,
        default: []
      ].append(dependency)
    }
    self.dependenciesByComponentName = dependenciesByComponentName
    var modulesByComponentName = [ComponentName: [Module]]()
    for module in modules {
      modulesByComponentName[
        module.componentName,
        default: []
      ].append(module)
    }
    self.modulesByComponentName = modulesByComponentName
  }

  func make() async -> FactoryResult<BindingGraph> {
    let network = UnweightedGraph<BindingGraph.Node>()
    await visit(component: componentTree.rootComponent, network: network)

    let bindingGraph = BindingGraph(
      rootComponent: componentTree.rootComponent,
      network: network
    )
    let reports = await validate(bindingGraph)
    return if reports.isEmpty {
      .success(bindingGraph)
    } else {
      .failure(reports)
    }
  }

  private func visit(
    component: Component,
    network: UnweightedGraph<BindingGraph.Node>,
    parentBindingsByKey: [Key: [Binding]]? = nil
  ) async {
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
    for binding in bindings {
      let bindingNode: BindingGraph.Node = .binding(binding)
      let bindingIndex = network.addVertex(bindingNode)
      network.addEdge(fromIndex: componentIndex, toIndex: bindingIndex, directed: true)
    }

    let reachableBindingsByKey = bindingsByKey.merging(parentBindingsByKey ?? [Key: [Binding]](), uniquingKeysWith: +)
    let resolvedBindings = await withTaskGroup(of: ResolvedBinding?.self) { group in
      for binding in bindings {
        group.addTask {
          resolveBinding(
            binding,
            reachableBindingsByKey: reachableBindingsByKey,
            network: network
          )
        }
      }
      var results = [ResolvedBinding]()
      for await result in group {
        if let result {
          results.append(result)
        }
      }
      return results
    }
    for resolvedBinding in resolvedBindings {
      for dependencyRequestResult in resolvedBinding.dependencyRequestResults {
        switch dependencyRequestResult {
        case .missing(let dependencyRequest):
          let missingBindingIndex = network.addVertex(.missingBinding(dependencyRequest))
          network.addEdgeIfNotExist(
            fromIndex: resolvedBinding.bindingIndex,
            toIndex: missingBindingIndex,
            directed: true
          )
        case .resolved(let index):
          network.addEdgeIfNotExist(fromIndex: resolvedBinding.bindingIndex, toIndex: index, directed: true)
        }
      }
    }
    for subcomponent in (componentTree.subcomponentsByParent[component.name] ?? []) {
      await visit(
        component: subcomponent,
        network: network,
        parentBindingsByKey: reachableBindingsByKey
      )
      if let subcomponentIndex = network.indexOfVertex(.component(subcomponent)) {
        network.addEdgeIfNotExist(fromIndex: componentIndex, toIndex: subcomponentIndex, directed: true)
      }
    }
  }

  private func resolveBinding(
    _ binding: Binding,
    reachableBindingsByKey: [Key: [Binding]],
    network: UnweightedGraph<BindingGraph.Node>
  ) -> ResolvedBinding? {
    guard let bindingIndex = network.indexOfVertex(.binding(binding)) else { return nil }

    let dependencyRequestResults = binding.dependencyRequests.flatMap {
      dependencyRequest -> [ResolvedBinding.DependencyRequestResult] in
      let resolvedBindings = reachableBindingsByKey[dependencyRequest.key] ?? []
      if resolvedBindings.isEmpty {
        return [.missing(dependencyRequest: dependencyRequest)]
      } else {
        return resolvedBindings.compactMap { resolvedBinding in
          let resolvedBindingNode = BindingGraph.Node.binding(resolvedBinding)
          guard let index = network.indexOfVertex(resolvedBindingNode) else { return nil }

          return .resolved(index: index)
        }
      }
    }
    return ResolvedBinding(
      bindingIndex: bindingIndex,
      dependencyRequestResults: dependencyRequestResults
    )
  }

  private func validate(_ bindingGraph: BindingGraph) async -> [Report] {
    let (bindingsByKey, missingDependencyRequests) = bindingGraph.nodes.reduce(
      into: ([Key: [Binding]](), [DependencyRequest]())
    ) { result, node in
      switch node {
      case .component:
        break
      case .binding(let binding):
        result.0[binding.key, default: []].append(binding)
      case .missingBinding(let dependencyRequest):
        result.1.append(dependencyRequest)
      }
    }
    let bindingsList = bindingsByKey.values
    let bindings = bindingsList.flatMap { $0 }

    return await withTaskGroup(of: [Report].self) { group in
      group.addTask {
        var reports = [Report]()
        for bindings in bindingsList {
          if bindings.count > 1 {
            for binding in bindings {
              reports.append(
                Report(
                  message: "\(binding.type.value) is duplicate",
                  severity: .error,
                  location: binding.location
                )
              )
            }
          }
        }
        return reports
      }
      group.addTask {
        var reports = [Report]()

        let requiredBindingsByBinding = await withTaskGroup(of: [Binding: [Binding]].self) { group in
          for binding in bindings {
            group.addTask {
              let requiredBindings = bindingGraph.requiredBindings(for: binding)
              return [binding: requiredBindings]
            }
          }
          var results: [Binding: [Binding]] = [:]
          for await result in group {
            results.merge(result, uniquingKeysWith: +)
          }

          return results
        }

        for (binding, requiredBindings) in requiredBindingsByBinding {
          for requiredBinding in requiredBindings {
            switch requiredBinding.kind {
            case .registration(let parameters, _, _, _):
              if parameters.contains(where: \.isAssisted) {
                reports.append(
                  Report(
                    message:
                      "Sword does not support the injection of dependencies with @Assisted parameters, \(requiredBinding.type.value)",
                    severity: .error,
                    location: binding.location
                  )
                )
              }
            case .componentArgument:
              break
            }
          }
        }

        return reports
      }
      group.addTask {
        var reports = [Report]()
        for missingDependencyRequest in missingDependencyRequests {
          reports.append(
            Report(
              message: "\(missingDependencyRequest.type.value) is missing",
              severity: .error,
              location: missingDependencyRequest.location
            )
          )
        }
        return reports
      }

      if bindingGraph.isDAG {
        group.addTask {
          var reports = [Report]()
          for binding in bindings {
            switch binding.kind {
            case .registration(_, _, _, let scope):
              guard let scope else { break }

              switch scope {
              case .single:
                detectCaptiveDependency(
                  bindingGraph: bindingGraph,
                  binding: binding,
                  originalBinding: binding,
                  reports: &reports
                )
              case .weakReference:
                break
              }
            case .componentArgument:
              break
            }
          }
          return reports
        }
      } else {
        group.addTask {
          var reports = [Report]()
          for cycle in bindingGraph.cycles {
            for node in cycle {
              switch node {
              case .component(let component):
                reports.append(
                  Report(
                    message: "A component cycle is found",
                    severity: .error,
                    location: component.location
                  )
                )
              case .binding(let binding):
                reports.append(
                  Report(
                    message: "A dependency cycle is found",
                    severity: .error,
                    location: binding.location
                  )
                )
              case .missingBinding:
                break
              }
            }
          }
          return reports
        }
      }

      var results = [Report]()
      for await result in group {
        results.append(contentsOf: result)
      }
      return results
    }
  }

  private func detectCaptiveDependency(
    bindingGraph: BindingGraph,
    binding: Binding,
    originalBinding: Binding,
    reports: inout [Report]
  ) {
    let requiredBindings = bindingGraph.requiredBindings(for: binding)
    for requiredBinding in requiredBindings {
      switch requiredBinding.kind {
      case .registration(_, _, _, let scope):
        if let scope {
          switch scope {
          case .single: break
          case .weakReference:
            reports.append(
              Report(
                message: "A captive dependency found, \(requiredBinding.type.value)",
                severity: .error,
                location: originalBinding.location
              )
            )
          }
        }
      case .componentArgument: break
      }

      detectCaptiveDependency(
        bindingGraph: bindingGraph,
        binding: requiredBinding,
        originalBinding: originalBinding,
        reports: &reports
      )
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
