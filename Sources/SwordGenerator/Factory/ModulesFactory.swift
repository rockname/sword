struct ModulesFactory: Factory {
  let moduleDescriptors: [ModuleDescriptor]

  func make() async -> FactoryResult<[Module]> {
    var providerFactoryResultsByModuleDescriptor = [ModuleDescriptor: [FactoryResult<Provider>]]()
    for moduleDescriptor in moduleDescriptors {
      let providerFactoryResults = await withTaskGroup(of: FactoryResult<Provider>.self) { group in
        for provider in moduleDescriptor.providers {
          group.addTask {
            var reports = [Report]()
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
              return .failure(reports)
            }

            return if reports.isEmpty {
              .success(
                Provider(
                  moduleName: moduleDescriptor.name,
                  name: provider.name,
                  type: returnType,
                  parameters: provider.parameters,
                  hasMainActor: provider.hasMainActor,
                  scope: provider.scope,
                  location: provider.location
                )
              )
            } else {
              .failure(reports)
            }
          }
        }
        var results = [FactoryResult<Provider>]()
        for await result in group {
          results.append(result)
        }
        return results
      }
      providerFactoryResultsByModuleDescriptor[moduleDescriptor] = providerFactoryResults
    }
    let (providersByModuleDescriptor, reports) = providerFactoryResultsByModuleDescriptor.reduce(
      into: ([ModuleDescriptor: [Provider]](), [Report]())
    ) { result, providerFactoryResults in
      for providerFactoryResult in providerFactoryResults.value {
        switch providerFactoryResult {
        case .success(let provider): result.0[providerFactoryResults.key, default: []].append(provider)
        case .failure(let reports): result.1.append(contentsOf: reports)
        }
      }
    }
    return if reports.isEmpty {
      .success(
        providersByModuleDescriptor.map { moduleDescriptor, providers in
          Module(
            name: moduleDescriptor.name,
            componentName: moduleDescriptor.componentName,
            providers: providers
          )
        }
      )
    } else {
      .failure(reports)
    }
  }
}
