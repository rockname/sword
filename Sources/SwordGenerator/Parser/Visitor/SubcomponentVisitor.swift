import SwiftSyntax
import SwiftSyntaxSupport
import SwordComponentArgument

final class SubcomponentVisitor: SourceFileVisitor<SubcomponentDescriptor> {
  private struct SubcomponentAttribute {
    let parent: String
    let arguments: [ComponentArgument]
  }

  override func visitPost(_ node: ClassDeclSyntax) {
    if let subcomponentAttribute = extractSubcomponentAttribute(from: node.attributes) {
      results.append(
        SubcomponentDescriptor(
          name: ComponentName(value: node.name.text),
          arguments: subcomponentAttribute.arguments,
          parentName: subcomponentAttribute.parent,
          location: node.startLocation(converter: locationConverter)
        )
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
    let componentArguments = arguments.filter { $0.label?.text != "of" }.compactMap {
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
