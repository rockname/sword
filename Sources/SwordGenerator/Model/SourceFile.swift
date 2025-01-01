import Foundation
import SwiftSyntax

package struct SourceFile {
  package let path: String
  package let tree: SourceFileSyntax

  package init(path: String, tree: SourceFileSyntax) {
    self.path = path
    self.tree = tree
  }
}
