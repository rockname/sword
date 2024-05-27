import Foundation
import SwiftSyntax

final class ImportRegistry {
  private var _imports = Set<Import>()
  var imports: [Import] {
    _imports.sorted { $0.path < $1.path }
  }

  func register(_ declaration: ImportDeclSyntax) {
    _imports.insert(
      Import(
        path: "\(declaration.path)",
        kind: declaration.importKindSpecifier?.text
      )
    )
  }

  func register(_ target: String) {
    _imports.insert(Import(path: target))
  }
}
