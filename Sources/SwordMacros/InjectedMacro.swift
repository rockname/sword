import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct InjectedMacro {

}

extension InjectedMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.is(InitializerDeclSyntax.self) else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Injected' must be applied to initializer",
        id: .invalidApplication
      )
    }

    return []
  }
}
