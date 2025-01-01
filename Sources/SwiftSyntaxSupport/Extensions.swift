import SwiftSyntax

extension DeclGroupSyntax {
  package var isPublic: Bool {
    modifiers.first(where: { $0.name.tokenKind == .keyword(.public) }) != nil
  }
}

extension LabeledExprListSyntax {
  package var argumentByLabel: [String: ExprSyntax] {
    var result = [String: ExprSyntax]()
    for labeledExpr in self {
      result[labeledExpr.label!.text] = labeledExpr.expression
    }
    return result
  }
}
