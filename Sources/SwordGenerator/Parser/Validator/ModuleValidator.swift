import Foundation

struct ModuleValidator {
  private let moduleRegistry: ModuleRegistry

  init(moduleRegistry: ModuleRegistry) {
    self.moduleRegistry = moduleRegistry
  }

  func validate() -> ValidationResult<[ComponentName: [Module]]> {
    var reports = [Report]()
    var modulesByComponentName = [ComponentName: [Module]]()

    for (componentName, descriptors) in moduleRegistry.descriptorsByComponentName {
      for descriptor in descriptors {
        var providers = [Provider]()

        for provider in descriptor.providers {
          if !provider.isStaticFunction {
            reports.append(
              Report(
                message: "'@Provider' must be static function",
                severity: .error,
                location: provider.location
              )
            )
          }

          if provider.parameters.contains(where: { $0.isAssisted }), provider.scope != nil {
            reports.append(
              Report(
                message: "'@Provider' must not set scope when having '@Assisted' parameter",
                severity: .error,
                location: provider.location
              )
            )
          }

          guard let returnType = provider.returnType else {
            reports.append(
              Report(
                message: "'@Provider' must have return type",
                severity: .error,
                location: provider.location
              )
            )
            continue
          }

          providers.append(
            Provider(
              moduleName: descriptor.name,
              name: provider.name,
              type: returnType,
              parameters: provider.parameters,
              hasMainActorAttribute: provider.hasMainActorAttribute,
              scope: provider.scope,
              location: provider.location
            )
          )
        }

        modulesByComponentName[componentName, default: []].append(
          Module(
            name: descriptor.name,
            providers: providers
          )
        )
      }
    }

    if reports.isEmpty {
      return .valid(modulesByComponentName)
    } else {
      return .invalid(reports)
    }
  }
}
