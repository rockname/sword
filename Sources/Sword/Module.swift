import Foundation

@attached(peer)
public macro Module(
  registeredTo component: any Component.Type
) = #externalMacro(module: "SwordMacros", type: "ModuleMacro")
