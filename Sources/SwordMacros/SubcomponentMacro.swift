import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxSupport
import SwordComponentArgument

public struct SubcomponentMacro {
  static let conformanceName = "Subcomponent"
  static var qualifiedConformanceName: String {
    "\(moduleName).\(conformanceName)"
  }

  static func initializer(
    parent: String,
    arguments: [ComponentArgument],
    accessModifier: String? = nil
  ) -> DeclSyntax {
    """
    \(raw: accessModifier ?? "") init(
    \(raw: initializerParameters(parent: parent, arguments: arguments))
    ) {
    self.parent = parent
    \(raw: ComponentMacro.initializerBody(arguments))
    }
    """
  }
  static func initializerParameters(parent: String, arguments: [ComponentArgument])
    -> FunctionParameterListSyntax
  {
    var parameters = FunctionParameterListSyntax([
      FunctionParameterSyntax(
        firstName: .identifier("parent"),
        type: TypeSyntax(stringLiteral: parent),
        trailingComma: arguments.isEmpty ? nil : .commaToken(trailingTrivia: .newline)
      )
    ])
    parameters.append(contentsOf: ComponentMacro.initializerParameters(arguments))
    return parameters
  }
}

extension SubcomponentMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard
      case let .argumentList(arguments) = node.arguments,
      let parent = arguments.first?.expression
        .as(MemberAccessExprSyntax.self)?.base?
        .as(DeclReferenceExprSyntax.self)?.baseName.text
    else { return [] }

    let accessModifier = declaration.isPublic ? "public" : nil
    let decl: DeclSyntax = """
      extension \(raw: type.trimmedDescription): \(raw: qualifiedConformanceName) {
      \(raw: accessModifier ?? "") subscript<T>(dynamicMember keyPath: KeyPath<\(raw: parent), T>) -> T {
      parent[keyPath: keyPath]
      }
      }
      """
    let extensionDecl = decl.cast(ExtensionDeclSyntax.self)
    return [extensionDecl]
  }
}

extension SubcomponentMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let classDeclaration = declaration.as(ClassDeclSyntax.self) else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Subcomponent' must be applied to class type",
        id: .invalidApplication
      )
    }

    guard
      case let .argumentList(arguments) = node.arguments,
      let parent = arguments.first?.expression
        .as(MemberAccessExprSyntax.self)?.base?
        .as(DeclReferenceExprSyntax.self)?.baseName.text
    else {
      throw DiagnosticsError(syntax: node, message: "Invalid arguments", id: .invalidArguments)
    }

    let location = context.location(of: node, at: .afterLeadingTrivia, filePathMode: .filePath)!
    let componentArguments = arguments.dropFirst().base.compactMap {
      ComponentArgument(
        element: $0,
        location: SourceLocation(
          line: Int("\(location.line)")!,
          column: Int("\(location.column)")!,
          offset: 0,
          file: "\(location.file)"
        )
      )
    }
    let accessModifier = classDeclaration.isPublic ? "public" : nil
    let parentVariable: DeclSyntax =
      """
      private let parent: \(raw: parent)
      """
    return ComponentMacro.storedProperties(for: componentArguments, accessModifier: accessModifier)
      + [
        parentVariable,
        initializer(
          parent: parent,
          arguments: componentArguments,
          accessModifier: accessModifier
        ),
        ComponentMacro.withSingleFunction(accessModifier: accessModifier),
        ComponentMacro.instanceStoreVariable,
      ]
  }
}
