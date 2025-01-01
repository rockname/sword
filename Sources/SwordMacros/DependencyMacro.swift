import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct DependencyMacro {

}

extension DependencyMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard
      declaration.is(StructDeclSyntax.self)
        || declaration.is(ClassDeclSyntax.self)
        || declaration.is(ActorDeclSyntax.self)
    else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Dependency' must be applied to struct, class or actor type",
        id: .invalidApplication
      )
    }

    return []
  }
}
