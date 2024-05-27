import Foundation
import SwiftSyntax

final class ComponentTreeValidator {
  private let componentTree: ComponentTree

  init(componentTree: ComponentTree) {
    self.componentTree = componentTree
  }

  func validate() -> ValidationResult<Void> {
    var reports = [Report]()

    let resolvedBindingsByRequest = resolve(componentTree: componentTree)
    for (request, resolvedBindings) in resolvedBindingsByRequest {
      if resolvedBindings.bindings.isEmpty {
        reports.append(
          Report(
            message: "\(request.type.value) is missing",
            severity: .error,
            location: request.location
          )
        )
      } else if resolvedBindings.bindings.count > 1 {
        for binding in resolvedBindings.bindings {
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

    if reports.isEmpty {
      return .valid(())
    } else {
      return .invalid(reports)
    }
  }

  private func resolve(
    componentTree: ComponentTree,
    parentResolver: Resolver? = nil
  ) -> [BindingRequest: ResolvedBindings] {
    let resolver = Resolver(
      bindingsByKey: componentTree.bindingsByKey,
      parentResolver: parentResolver
    )
    let resolvedRequests = resolver.resolve()

    let subResolvedRequests = componentTree.subcomponentTrees.flatMap { subcomponentTree in
      resolve(componentTree: subcomponentTree, parentResolver: resolver)
    }

    return resolvedRequests.merging(subResolvedRequests, uniquingKeysWith: { (first, _) in first })
  }
}
