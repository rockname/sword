import SwiftGraph
import SwiftSyntax
import SwordFoundation

struct BindingGraphValidator {
  private let bindingGraph: BindingGraph

  init(bindingGraph: BindingGraph) {
    self.bindingGraph = bindingGraph
  }

  func validate() -> ValidationResult<Void> {
    var bindingsByKey = [Key: [Binding]]()
    var missingDependencyRequests = [DependencyRequest]()
    for node in bindingGraph.nodes {
      switch node {
      case .component:
        break
      case .binding(let binding):
        bindingsByKey[binding.key, default: []].append(binding)
      case .missingBinding(let dependencyRequest):
        missingDependencyRequests.append(dependencyRequest)
      }
    }

    var reports = [Report]()
    for bindings in bindingsByKey.values {
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
    for missingDependencyRequest in missingDependencyRequests {
      reports.append(
        Report(
          message: "\(missingDependencyRequest.type.value) is missing",
          severity: .error,
          location: missingDependencyRequest.location
        )
      )
    }
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

    if reports.isEmpty {
      return .valid(())
    } else {
      return .invalid(reports)
    }
  }
}