import Foundation

@dynamicMemberLookup
public protocol Subcomponent: Component {
  associatedtype Parent: Component
  subscript<T>(dynamicMember keyPath: KeyPath<Parent, T>) -> T { get }
}

@attached(
  member,
  names: named(parent),
  named(_instanceStore),
  named(withSingle(_:_:)),
  arbitrary
)
@attached(
  extension,
  conformances: Subcomponent,
  names: arbitrary
)
public macro Subcomponent(
  of parent: any Component.Type,
  arguments: ComponentArgument...
) = #externalMacro(module: "SwordMacros", type: "SubcomponentMacro")
