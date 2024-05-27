import SwiftSyntax

extension AttributeListSyntax {
  func first(named name: String) -> AttributeSyntax? {
    self.first { attribute in
      guard
        let attribute = attribute.as(AttributeSyntax.self),
        let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)
      else { return false }

      return attributeName.name.text == name
    }?.as(AttributeSyntax.self)
  }
}
