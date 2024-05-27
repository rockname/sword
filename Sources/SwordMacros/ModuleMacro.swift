import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct ModuleMacro {

}

extension ModuleMacro: PeerMacro {
  public static func expansion(
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
