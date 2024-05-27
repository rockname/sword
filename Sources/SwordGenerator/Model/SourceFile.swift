import Foundation
import SwiftSyntax

public struct SourceFile {
  public let path: String
  public let tree: SourceFileSyntax

  public init(path: String, tree: SourceFileSyntax) {
    self.path = path
    self.tree = tree
  }
}
