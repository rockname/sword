import Foundation

struct DependenciesFactory: Factory {
  let dependencyDescriptors: [DependencyDescriptor]

  func make() async -> FactoryResult<[Dependency]> {
    let dependencyFactoryResults = await withTaskGroup(of: FactoryResult<Dependency>.self) { group in
      for dependencyDescriptor in dependencyDescriptors {
        group.addTask {
          var reports = [Report]()
          if !dependencyDescriptor.isReferenceType, dependencyDescriptor.scope != nil {
            reports.append(
              Report(
                message: "Scoped '@Dependency' must be reference type",
                severity: .error,
                location: dependencyDescriptor.location
              )
            )
          }

          if dependencyDescriptor.injectedInitializers.count > 1 {
            reports.append(
              Report(
                message: "'@Dependency' must have just one '@Injected' initializer",
                severity: .error,
                location: dependencyDescriptor.location
              )
            )
          }

          guard let injectedInitializer = dependencyDescriptor.injectedInitializers.first else {
            reports.append(
              Report(
                message: "'@Dependency' requires an '@Injected' initializer",
                severity: .error,
                location: dependencyDescriptor.location
              )
            )
            return .failure(reports)
          }

          if injectedInitializer.parameters.contains(where: { $0.isAssisted }), dependencyDescriptor.scope != nil {
            reports.append(
              Report(
                message: "'@Dependency' must not set scope when having '@Assisted' parameter",
                severity: .error,
                location: dependencyDescriptor.location
              )
            )
          }

          return if reports.isEmpty {
            .success(
              Dependency(
                type: dependencyDescriptor.type,
                componentName: dependencyDescriptor.componentName,
                interface: dependencyDescriptor.interface,
                initializer: injectedInitializer,
                hasMainActor: dependencyDescriptor.hasMainActor,
                scope: dependencyDescriptor.scope,
                location: dependencyDescriptor.location
              )
            )
          } else {
            .failure(reports)
          }
        }
      }
      var results = [FactoryResult<Dependency>]()
      for await result in group {
        results.append(result)
      }
      return results
    }

    let (dependencies, reports) = dependencyFactoryResults.reduce(
      into: ([Dependency](), [Report]())
    ) { result, dependencyFactoryResult in
      switch dependencyFactoryResult {
      case .success(let dependency): result.0.append(dependency)
      case .failure(let reports): result.1.append(contentsOf: reports)
      }
    }
    return if reports.isEmpty {
      .success(dependencies)
    } else {
      .failure(reports)
    }
  }
}
