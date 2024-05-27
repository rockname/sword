import Foundation

struct ComponentValidator {
  private let componentRegistry: ComponentRegistry

  init(componentRegistry: ComponentRegistry) {
    self.componentRegistry = componentRegistry
  }

  func validate() -> ValidationResult<(ComponentNode, [ComponentName: [ComponentNode]])> {
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

    return .valid(
      (
        ComponentNode(
          name: component.name,
          arguments: component.arguments
        ),
        componentRegistry.subcomponentsByParent.mapValues { subcomponents in
          subcomponents.map { subcomponent in
            ComponentNode(
              name: subcomponent.name,
              arguments: subcomponent.arguments
            )
          }
        }
      )
    )
  }
}
