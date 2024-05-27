import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct DependencyMacro {

}

extension DependencyMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Dependency' must be applied to struct or class type",
        id: .invalidApplication
      )
    }

    return []
  }
}
