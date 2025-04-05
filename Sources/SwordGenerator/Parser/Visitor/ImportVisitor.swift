import SwiftSyntax

final class ImportVisitor: SourceFileVisitor<Import> {
  override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
    results.append(
      Import(
        path: "\(node.trimmed.path)",
        kind: node.trimmed.importKindSpecifier?.text
      )
    )
    return .skipChildren
  }
}
