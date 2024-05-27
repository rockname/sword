import Foundation

@attached(peer)
public macro Dependency(
  registeredTo component: any Component.Type,
  boundTo interface: Any.Type? = nil,
  scopedWith scope: Scope? = nil
) = #externalMacro(module: "SwordMacros", type: "DependencyMacro")
