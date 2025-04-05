import SwiftSyntax
import SwiftSyntaxSupport
import SwordComponentArgument

final class ComponentVisitor: SourceFileVisitor<RootComponentDescriptor> {
  private struct ComponentAttribute {
    let arguments: [ComponentArgument]
  }

  override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
    guard let componentAttribute = extractComponentAttribute(from: node.attributes) else { return .skipChildren }

    results.append(
      RootComponentDescriptor(
        name: ComponentName(value: node.name.text),
        arguments: componentAttribute.arguments,
        location: node.startLocation(converter: locationConverter)
      )
    )
    return .skipChildren
  }

  private func extractComponentAttribute(from attributes: AttributeListSyntax)
    -> ComponentAttribute?
  {
    guard let componentAttribute = attributes.first(named: "Component") else {
      return nil
    }

    let location = attributes.startLocation(converter: locationConverter)
    let componentArguments: [ComponentArgument] =
      if let arguments = componentAttribute.arguments?.as(LabeledExprListSyntax.self) {
        arguments.compactMap {
          ComponentArgument(
            element: $0,
            location: location
          )
        }
      } else {
        []
      }

    return ComponentAttribute(arguments: componentArguments)
  }
}
