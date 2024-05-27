import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct ProviderMacro {

}

extension ProviderMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.is(FunctionDeclSyntax.self) else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Provider' must be applied to function",
        id: .invalidApplication
      )
    }

    return []
  }
}
