struct ComponentTreeFactory: Factory {
  let rootComponentDescriptors: [RootComponentDescriptor]
  let subcomponentDescriptors: [SubcomponentDescriptor]

  func make() async -> FactoryResult<ComponentTree> {
    guard let rootComponentDescriptor = rootComponentDescriptors.first else {
      return .failure([
        Report(
          message: "'@Component' must be declared",
          severity: .error
        )
      ])
    }

    if rootComponentDescriptors.count > 1 {
      return .failure([
        Report(
          message: "'@Component' must be just one",
          severity: .error
        )
      ])
    }

    var subcomponentsByParent = [ComponentName: [Component]]()
    for subcomponentDescriptor in subcomponentDescriptors {
      subcomponentsByParent[ComponentName(value: subcomponentDescriptor.parentName), default: []].append(
        Component(
          name: subcomponentDescriptor.name,
          arguments: subcomponentDescriptor.arguments,
          parentComponentName: ComponentName(value: subcomponentDescriptor.parentName),
          location: subcomponentDescriptor.location
        )
      )
    }

    return .success(
      ComponentTree(
        rootComponent: Component(
          name: rootComponentDescriptor.name,
          arguments: rootComponentDescriptor.arguments,
          parentComponentName: nil,
          location: rootComponentDescriptor.location
        ),
        subcomponentsByParent: subcomponentsByParent
      )
    )
  }
}
