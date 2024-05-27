import SwiftSyntax
import SwiftSyntaxSupport
import SwordComponentArgument

final class ComponentVisitor: SyntaxVisitor {
  private struct ComponentAttribute {
    let arguments: [ComponentArgument]
  }

  private let componentRegistry: ComponentRegistry
  private let locationConverter: SourceLocationConverter

  init(
    componentRegistry: ComponentRegistry,
    sourceFile: SourceFile
  ) {
    self.componentRegistry = componentRegistry
    self.locationConverter = SourceLocationConverter(
      fileName: sourceFile.path,
      tree: sourceFile.tree
    )
    super.init(viewMode: .sourceAccurate)
  }

  override func visitPost(_ node: ClassDeclSyntax) {
    guard let componentAttribute = extractComponentAttribute(from: node.attributes) else { return }

    componentRegistry.register(
      RootComponentDescriptor(
        name: ComponentName(value: node.name.text),
        arguments: componentAttribute.arguments
      )
    )
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
