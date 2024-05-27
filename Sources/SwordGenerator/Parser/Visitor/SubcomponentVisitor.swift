import SwiftSyntax
import SwiftSyntaxSupport
import SwordComponentArgument

final class SubcomponentVisitor: SyntaxVisitor {
  private struct SubcomponentAttribute {
    let parent: String
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
    if let subcomponentAttribute = extractSubcomponentAttribute(from: node.attributes) {
      componentRegistry.register(
        SubcomponentDescriptor(
          name: ComponentName(value: node.name.text),
          arguments: subcomponentAttribute.arguments,
          parentName: subcomponentAttribute.parent
        ),
        by: ComponentName(value: subcomponentAttribute.parent)
      )
    }
  }

  private func extractSubcomponentAttribute(from attributes: AttributeListSyntax)
    -> SubcomponentAttribute?
  {
    guard let subcomponentAttribute = attributes.first(named: "Subcomponent") else {
      return nil
    }

    guard let arguments = subcomponentAttribute.arguments?.as(LabeledExprListSyntax.self) else {
      return nil
    }

    let argumentByLabel = arguments.argumentByLabel
    guard let parentComponent = argumentByLabel["of"]?.as(MemberAccessExprSyntax.self)?.base else {
      return nil
    }

    let location = attributes.startLocation(converter: locationConverter)
    let componentArguments = arguments.dropFirst().base.compactMap {
      ComponentArgument(
        element: $0,
        location: location
      )
    }

    return SubcomponentAttribute(
      parent: "\(parentComponent)",
      arguments: componentArguments
    )
  }
}
