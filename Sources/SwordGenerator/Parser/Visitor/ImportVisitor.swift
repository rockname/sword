import SwiftSyntax

final class ImportVisitor: SourceFileVisitor<Import> {
  override func visitPost(_ node: ImportDeclSyntax) {
    results.append(
      Import(
        path: "\(node.trimmed.path)",
        kind: node.trimmed.importKindSpecifier?.text
      )
    )
  }
}
