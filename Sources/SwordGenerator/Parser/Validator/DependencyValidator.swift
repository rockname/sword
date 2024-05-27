import Foundation

struct DependencyValidator {
  let dependencyRegistry: DependencyRegistry

  func validate() -> ValidationResult<[ComponentName: [Dependency]]> {
    var reports = [Report]()
    var dependenciesByComponentName = [ComponentName: [Dependency]]()
    for (componentName, descriptors) in dependencyRegistry.descriptorsByComponentName {
      for descriptor in descriptors {
        if !descriptor.isClass, descriptor.scope != nil {
          reports.append(
            Report(
              message: "Scoped '@Dependency' must be class type",
              severity: .error,
              location: descriptor.location
            )
          )
          continue
        }

        guard let injectedInitializer = descriptor.injectedInitializers.first else {
          reports.append(
            Report(
              message: "'@Dependency' requires an '@Injected' initializer",
              severity: .error,
              location: descriptor.location
            )
          )
          continue
        }

        if descriptor.injectedInitializers.count > 1 {
          reports.append(
            Report(
              message: "'@Dependency' must have just one '@Injected' initializer",
              severity: .error,
              location: descriptor.location
            )
          )
          continue
        }

        if injectedInitializer.parameters.contains(where: { $0.isAssisted }), descriptor.scope != nil {
          reports.append(
            Report(
              message: "'@Dependency' must not set scope when having '@Assisted' parameter",
              severity: .error,
              location: descriptor.location
            )
          )
          continue
        }

        dependenciesByComponentName[componentName, default: []].append(
          Dependency(
            type: descriptor.type,
            interface: descriptor.interface,
            initializer: injectedInitializer,
            scope: descriptor.scope,
            location: descriptor.location
          )
        )
      }
    }
    if reports.isEmpty {
      return .valid(dependenciesByComponentName)
    } else {
      return .invalid(reports)
    }
  }
}
