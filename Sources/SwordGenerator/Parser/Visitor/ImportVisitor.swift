import SwiftSyntax

final class ImportVisitor: SyntaxVisitor {
  private let importRegistry: ImportRegistry
  private let locationConverter: SourceLocationConverter

  init(
    importRegistry: ImportRegistry,
    sourceFile: SourceFile
  ) {
    self.importRegistry = importRegistry
    self.locationConverter = SourceLocationConverter(
      fileName: sourceFile.path,
      tree: sourceFile.tree
    )
    super.init(viewMode: .sourceAccurate)
  }

  override func visitPost(_ node: ImportDeclSyntax) {
    importRegistry.register(node.trimmed)
  }
}
