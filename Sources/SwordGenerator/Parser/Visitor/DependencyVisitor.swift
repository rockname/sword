import SwiftSyntax
import SwordFoundation

final class DependencyVisitor: SourceFileVisitor<DependencyDescriptor> {
  private struct DependencyAttribute {
    let component: String
    let interface: String?
    let scope: Scope?
  }

  override func visitPost(_ node: StructDeclSyntax) {
    registerDependencyIfNeeded(
      name: node.name,
      attributes: node.attributes,
      members: node.memberBlock.members,
      isReferenceType: false
    )
  }

  override func visitPost(_ node: ClassDeclSyntax) {
    registerDependencyIfNeeded(
      name: node.name,
      attributes: node.attributes,
      members: node.memberBlock.members,
      isReferenceType: true
    )
  }

  override func visitPost(_ node: ActorDeclSyntax) {
    registerDependencyIfNeeded(
      name: node.name,
      attributes: node.attributes,
      members: node.memberBlock.members,
      isReferenceType: true
    )
  }

  private func registerDependencyIfNeeded(
    name: TokenSyntax,
    attributes: AttributeListSyntax,
    members: MemberBlockItemListSyntax,
    isReferenceType: Bool
  ) {
    guard let dependencyAttribute = extractDependencyAttribute(from: attributes) else { return }

    let location = attributes.startLocation(converter: locationConverter)
    let injectedInitializers =
      members
      .compactMap { member in
        member.decl.as(InitializerDeclSyntax.self)
      }
      .filter { initializer in
        initializer.attributes.first(named: "Injected") != nil
      }
      .map { parameter in
        Initializer(
          parameters: parameter.signature.parameterClause.parameters.compactMap { parameter in
            let parameterType = Type(value: "\(parameter.type.trimmed)")
            return Parameter(
              key: Key(type: parameterType),
              type: parameterType,
              name: parameter.firstName.text,
              isAssisted: parameter.attributes.first(named: "Assisted") != nil,
              location: parameter.startLocation(converter: locationConverter)
            )
          }
        )
      }
    let hasMainActor = attributes.first(named: "MainActor") != nil
    let dependencyDescriptor = DependencyDescriptor(
      componentName: ComponentName(value: dependencyAttribute.component),
      type: Type(value: name.text),
      interface: dependencyAttribute.interface.map(Interface.init),
      injectedInitializers: injectedInitializers,
      hasMainActor: hasMainActor,
      scope: dependencyAttribute.scope,
      isReferenceType: isReferenceType,
      location: location
    )
    results.append(dependencyDescriptor)
  }

  private func extractDependencyAttribute(from attributes: AttributeListSyntax)
    -> DependencyAttribute?
  {
    guard let dependencyAttribute = attributes.first(named: "Dependency") else {
      return nil
    }

    guard let arguments = dependencyAttribute.arguments?.as(LabeledExprListSyntax.self) else {
      return nil
    }

    let argumentByLabel = arguments.argumentByLabel
    guard let component = argumentByLabel["registeredTo"]?.as(MemberAccessExprSyntax.self)?.base
    else {
      return nil
    }

    let interface = argumentByLabel["boundTo"]?.as(MemberAccessExprSyntax.self)?.base
    let scope = argumentByLabel["scopedWith"]?.as(MemberAccessExprSyntax.self)?.declName

    return DependencyAttribute(
      component: "\(component)",
      interface: interface.map(String.init),
      scope: scope.map(String.init).flatMap(Scope.init(rawValue:))
    )
  }
}
