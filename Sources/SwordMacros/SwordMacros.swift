import SwiftCompilerPlugin
import SwiftSyntaxMacros

let moduleName = "Sword"

@main
struct SwordMacros: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    ComponentMacro.self,
    DependencyMacro.self,
    InjectedMacro.self,
    ModuleMacro.self,
    ProviderMacro.self,
    SubcomponentMacro.self,
  ]
}
