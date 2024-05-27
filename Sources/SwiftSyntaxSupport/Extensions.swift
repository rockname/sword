import SwiftSyntax

extension DeclGroupSyntax {
  public var isPublic: Bool {
    modifiers.first(where: { $0.name.tokenKind == .keyword(.public) }) != nil
  }
}

extension LabeledExprListSyntax {
  public var argumentByLabel: [String: ExprSyntax] {
    var result = [String: ExprSyntax]()
    for labeledExpr in self {
      result[labeledExpr.label!.text] = labeledExpr.expression
    }
    return result
  }
}
