import Foundation

struct ComponentValidator {
  private let componentRegistry: ComponentRegistry

  init(componentRegistry: ComponentRegistry) {
    self.componentRegistry = componentRegistry
  }

  func validate() -> ValidationResult<(Component, [ComponentName: [Component]])> {
    guard let component = componentRegistry.components.first else {
      return .invalid([
        Report(
          message: "'@Component' must be declared",
          severity: .error
        )
      ])
    }

    if componentRegistry.components.count > 1 {
      return .invalid([
        Report(
          message: "'@Component' must be just one",
          severity: .error
        )
      ])
    }

    var subcomponentsByParent = [ComponentName: [Component]]()

    for (parentName, subcomponents) in componentRegistry.subcomponentsByParent {
      subcomponentsByParent[parentName, default: []].append(
        contentsOf: subcomponents.map { subcomponent in
          Component(
            name: subcomponent.name,
            arguments: subcomponent.arguments,
            parentComponentName: parentName,
            location: subcomponent.location
          )
        }
      )
    }

    return .valid(
      (
        Component(
          name: component.name,
          arguments: component.arguments,
          parentComponentName: nil,
          location: component.location
        ),
        subcomponentsByParent
      )
    )
  }
}
