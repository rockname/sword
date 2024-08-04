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
  named(withWeakReference(_:_:)),
  arbitrary
)
@attached(
  extension,
  conformances: Subcomponent,
  names: arbitrary
)
public macro Subcomponent(
  of parent: any Component.Type,
  arguments: Any.Type...
) = #externalMacro(module: "SwordMacros", type: "SubcomponentMacro")
