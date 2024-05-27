import SwiftSyntax
import SwordFoundation

final class DependencyVisitor: SyntaxVisitor {
  private struct DependencyAttribute {
    let component: String
    let interface: String?
    let scope: Scope?
  }

  private let dependencyRegistry: DependencyRegistry
  private let locationConverter: SourceLocationConverter

  init(
    dependencyRegistry: DependencyRegistry,
    sourceFile: SourceFile
  ) {
    self.dependencyRegistry = dependencyRegistry
    self.locationConverter = SourceLocationConverter(
      fileName: sourceFile.path,
      tree: sourceFile.tree
    )
    super.init(viewMode: .sourceAccurate)
  }

  override func visitPost(_ node: StructDeclSyntax) {
    registerDependencyIfNeeded(
      name: node.name,
      attributes: node.attributes,
      members: node.memberBlock.members,
      isClass: false
    )
  }

  override func visitPost(_ node: ClassDeclSyntax) {
    registerDependencyIfNeeded(
      name: node.name,
      attributes: node.attributes,
      members: node.memberBlock.members,
      isClass: true
    )
  }

  private func registerDependencyIfNeeded(
    name: TokenSyntax,
    attributes: AttributeListSyntax,
    members: MemberBlockItemListSyntax,
    isClass: Bool
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
    let dependencyDescriptor = DependencyDescriptor(
      type: Type(value: name.text),
      interface: dependencyAttribute.interface.map(Interface.init),
      injectedInitializers: injectedInitializers,
      scope: dependencyAttribute.scope,
      isClass: isClass,
      location: location
    )
    dependencyRegistry.register(
      dependencyDescriptor,
      by: ComponentName(value: dependencyAttribute.component)
    )
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
