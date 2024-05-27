import Foundation

@attached(peer)
public macro Injected() = #externalMacro(module: "SwordMacros", type: "InjectedMacro")
