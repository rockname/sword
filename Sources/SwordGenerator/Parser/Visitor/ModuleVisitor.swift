import SwiftSyntax
import SwordFoundation

final class ModuleVisitor: SourceFileVisitor<ModuleDescriptor> {
  private struct ModuleAttribute {
    let component: String
  }

  private struct ProviderAttribute {
    let scope: Scope?
  }

  override func visitPost(_ node: StructDeclSyntax) {
    guard let moduleAttribute = extractModuleAttribute(from: node.attributes) else { return }

    let providers: [ProviderDescriptor] = node.memberBlock.members.compactMap { member in
      guard
        let function = member.decl.as(FunctionDeclSyntax.self),
        let providerAttribute = extractProviderAttribute(from: function)
      else { return nil }

      let parameters = function.signature.parameterClause.parameters.map { parameter in
        let parameterType = Type(value: "\(parameter.type.trimmed)")
        return Parameter(
          key: Key(type: parameterType),
          type: parameterType,
          name: parameter.firstName.text,
          isAssisted: parameter.attributes.first(named: "Assisted") != nil,
          location: parameter.startLocation(converter: locationConverter)
        )
      }
      let hasMainActor = function.attributes.first(named: "MainActor") != nil

      return ProviderDescriptor(
        name: function.name.text,
        isStaticFunction: function.modifiers.contains(where: {
          $0.name.text == "static"
        }),
        returnType: function.signature.returnClause.map { Type(value: "\($0.type.trimmed)") },
        parameters: parameters,
        hasMainActor: hasMainActor,
        scope: providerAttribute.scope,
        location: function.attributes.startLocation(converter: locationConverter)
      )
    }

    results.append(
      ModuleDescriptor(
        name: node.name.text,
        componentName: ComponentName(value: moduleAttribute.component),
        providers: providers
      )
    )
  }

  private func extractModuleAttribute(from attributes: AttributeListSyntax) -> ModuleAttribute? {
    guard let moduleAttribute = attributes.first(named: "Module") else {
      return nil
    }

    guard let arguments = moduleAttribute.arguments?.as(LabeledExprListSyntax.self) else {
      return nil
    }

    let argumentByLabel = arguments.argumentByLabel
    guard let component = argumentByLabel["registeredTo"]?.as(MemberAccessExprSyntax.self)?.base
    else {
      return nil
    }

    return ModuleAttribute(component: "\(component)")
  }

  private func extractProviderAttribute(from function: FunctionDeclSyntax) -> ProviderAttribute? {
    guard let providerAttribute = function.attributes.first(named: "Provider") else {
      return nil
    }

    let arguments = providerAttribute.arguments?.as(LabeledExprListSyntax.self)
    let argumentByLabel = arguments?.argumentByLabel
    let scope = argumentByLabel?["scopedWith"]?.as(MemberAccessExprSyntax.self)?.declName

    return ProviderAttribute(
      scope: scope.map(String.init).flatMap(Scope.init(rawValue:))
    )
  }
}
