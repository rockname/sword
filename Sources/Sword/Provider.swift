import Foundation

@attached(peer)
public macro Provider(
  scopedWith scope: Scope? = nil
) = #externalMacro(module: "SwordMacros", type: "ProviderMacro")
