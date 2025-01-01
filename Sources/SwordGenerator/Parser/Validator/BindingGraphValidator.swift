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
    for binding in bindingsByKey.values.flatMap({ $0 }) {
      let requiredBindings = bindingGraph.requiredBindings(for: binding)
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
    for missingDependencyRequest in missingDependencyRequests {
      reports.append(
        Report(
          message: "\(missingDependencyRequest.type.value) is missing",
          severity: .error,
          location: missingDependencyRequest.location
        )
      )
    }
    if bindingGraph.cycles.isEmpty {
      for binding in bindingsByKey.values.flatMap({ $0 }) {
        switch binding.kind {
        case .registration(_, _, _, let scope):
          guard let scope else { break }

          switch scope {
          case .single:
            detectCaptiveDependency(
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
    } else {
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
    }

    if reports.isEmpty {
      return .valid(())
    } else {
      return .invalid(reports)
    }
  }

  private func detectCaptiveDependency(
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
        binding: requiredBinding,
        originalBinding: originalBinding,
        reports: &reports
      )
    }
  }
}
