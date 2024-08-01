import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxSupport
import SwordComponentArgument

public struct ComponentMacro {
  static let conformanceName = "Component"
  static var qualifiedConformanceName: String {
    "\(moduleName).\(conformanceName)"
  }

  static let instanceStoreVariable: DeclSyntax =
    """
    private let _instanceStore = InstanceStore()
    """

  static func storedProperties(
    for arguments: [ComponentArgument],
    accessModifier: String? = nil
  ) -> [DeclSyntax] {
    arguments.map { argument -> DeclSyntax in
      "\(raw: accessModifier ?? "") let \(raw: argument.key.value): \(raw: argument.type.value)"
    }
  }

  static func initializer(
    arguments: [ComponentArgument],
    accessModifier: String? = nil
  ) -> DeclSyntax {
    """
    \(raw: accessModifier ?? "") init(
    \(raw: initializerParameters(arguments))
    ) {
    \(raw: initializerBody(arguments))
    }
    """
  }
  static func initializerParameters(_ arguments: [ComponentArgument]) -> FunctionParameterListSyntax {
    FunctionParameterListSyntax(
      arguments.enumerated().map { index, argument in
        FunctionParameterSyntax(
          firstName: .identifier(argument.key.value),
          type: IdentifierTypeSyntax(name: .identifier(argument.type.value)),
          trailingComma: index < (arguments.count - 1) ? .commaToken(trailingTrivia: .newline) : nil
        )
      }
    )
  }
  static func initializerBody(_ arguments: [ComponentArgument]) -> CodeBlockItemListSyntax {
    CodeBlockItemListSyntax(
      arguments.enumerated().map { index, argument in
        CodeBlockItemSyntax(
          item: CodeBlockItemSyntax.Item(
            InfixOperatorExprSyntax(
              leftOperand: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                period: .periodToken(),
                declName: DeclReferenceExprSyntax(baseName: .identifier(argument.key.value))
              ),
              operator: AssignmentExprSyntax(),
              rightOperand: DeclReferenceExprSyntax(baseName: .identifier(argument.key.value)),
              trailingTrivia: index < (arguments.count - 1) ? .newline : nil
            )
          )
        )
      }
    )
  }
  static func withSingleFunction(accessModifier: String? = nil) -> DeclSyntax {
    """
    \(raw: accessModifier ?? "") func withSingle<T: AnyObject>(
    _ function: String = #function,
    _ factory: () -> T
    ) -> T {
    _instanceStore.withSingle(function, factory)
    }
    """
  }
  static func withWeakReferenceFunction(accessModifier: String? = nil) -> DeclSyntax {
    """
    \(raw: accessModifier ?? "") func withWeakReference<T: AnyObject>(
    _ function: String = #function,
    _ factory: () -> T
    ) -> T {
    _instanceStore.withWeakReference(function, factory)
    }
    """
  }
}

extension ComponentMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    let decl: DeclSyntax = """
      extension \(raw: type.trimmedDescription): \(raw: qualifiedConformanceName) {
      }
      """
    let extensionDecl = decl.cast(ExtensionDeclSyntax.self)
    return [extensionDecl]
  }
}

extension ComponentMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let classDeclaration = declaration.as(ClassDeclSyntax.self) else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Component' must be applied to class type",
        id: .invalidApplication
      )
    }

    let location = context.location(of: node, at: .afterLeadingTrivia, filePathMode: .filePath)!

    let componentArguments: [ComponentArgument] =
      if case let .argumentList(arguments) = node.arguments {
        arguments.compactMap {
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
      } else {
        []
      }
    let accessModifier = classDeclaration.isPublic ? "public" : nil

    return storedProperties(for: componentArguments, accessModifier: accessModifier) + [
      initializer(arguments: componentArguments, accessModifier: accessModifier),
      withSingleFunction(accessModifier: accessModifier),
      withWeakReferenceFunction(accessModifier: accessModifier),
      instanceStoreVariable,
    ]
  }
}
