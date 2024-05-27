import Foundation

public protocol Component: AnyObject {}

@attached(
  member,
  names: named(_instanceStore),
  named(withSingle(_:_:)),
  arbitrary
)
@attached(
  extension,
  conformances: Component
)
public macro Component(arguments: ComponentArgument...) =
  #externalMacro(module: "SwordMacros", type: "ComponentMacro")
