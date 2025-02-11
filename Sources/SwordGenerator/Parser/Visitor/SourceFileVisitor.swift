import SwiftSyntax

class SourceFileVisitor<T>: SyntaxVisitor {
  let locationConverter: SourceLocationConverter
  var results = [T]()

  private let sourceFile: SourceFile

  init(sourceFile: SourceFile) {
    self.sourceFile = sourceFile
    self.locationConverter = SourceLocationConverter(
      fileName: sourceFile.path,
      tree: sourceFile.tree
    )
    super.init(viewMode: .sourceAccurate)
  }

  func walk() -> [T] {
    walk(sourceFile.tree)
    return results
  }
}
