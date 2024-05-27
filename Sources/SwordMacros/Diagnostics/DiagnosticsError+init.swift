import SwiftDiagnostics
import SwiftSyntax

extension DiagnosticsError {
  init<S: SyntaxProtocol>(
    syntax: S,
    message: String,
    domain: String = moduleName,
    id: SwordDiagnostic.ID,
    severity: DiagnosticSeverity = .error
  ) {
    self.init(diagnostics: [
      Diagnostic(
        node: Syntax(syntax),
        message: SwordDiagnostic(message: message, domain: domain, id: id, severity: severity)
      )
    ])
  }
}
