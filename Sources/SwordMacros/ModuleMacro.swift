import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct ModuleMacro {

}

extension ModuleMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.is(StructDeclSyntax.self) else {
      throw DiagnosticsError(
        syntax: node,
        message: "'@Module' must be applied to struct type",
        id: .invalidApplication
      )
    }

    return []
  }
}
