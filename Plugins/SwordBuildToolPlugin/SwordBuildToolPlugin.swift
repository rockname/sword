import Foundation
import PackagePlugin

@main
struct SwordBuildToolPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    guard let sourceModule = target.sourceModule else { return [] }

    let targets = transitiveTargets(for: sourceModule)
    let targetByName = Dictionary(targets.map { ($0.name, $0) }, uniquingKeysWith: { (first, _) in first })
    let targetSourceModules = targetByName.values.compactMap(\.sourceModule)
    let inputPaths = ([sourceModule] + targetSourceModules).flatMap { sourceModule in
      sourceModule.sourceFiles(withSuffix: "swift").map(\.path)
    }
    let output = context.pluginWorkDirectory.appending("Sword.generated.swift")
    var arguments = [String]()
    let targetNames = targetByName.keys
    if !targetNames.isEmpty {
      arguments += ["--targets"] + targetNames
    }
    if !inputPaths.isEmpty {
      arguments += ["--inputs"] + inputPaths.map(\.string)
    }
    arguments += ["--output", output.string]
    return [
      .buildCommand(
        displayName: "Run SwordCommand",
        executable: try context.tool(named: "SwordCommand").path,
        arguments: arguments,
        outputFiles: [output]
      )
    ]
  }

  private func transitiveTargets(for sourceModule: SourceModuleTarget) -> [Target] {
    sourceModule.dependencies.flatMap { dependency -> [Target] in
      switch dependency {
      case .target(let target):
        if case .macro = target.sourceModule?.kind {
          []
        } else {
          [target] + (target.sourceModule.map(transitiveTargets(for:)) ?? [])
        }
      case .product: []
      @unknown default: []
      }
    }
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwordBuildToolPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    let frameworkTargets = context.xcodeProject.targets.filter {
      if case .framework = $0.product?.kind {
        return true
      } else {
        return false
      }
    }
    let inputPaths = ([target] + frameworkTargets).flatMap { target in
      target.inputFiles
        .filter { $0.type == .source && $0.path.extension == "swift" }
        .map(\.path)
    }
    let output = context.pluginWorkDirectory.appending("Sword.generated.swift")
    var arguments = [String]()
    if !frameworkTargets.isEmpty {
      arguments += ["--targets"] + frameworkTargets.map(\.displayName)
    }
    if !inputPaths.isEmpty {
      arguments += ["--inputs"] + inputPaths.map(\.string)
    }
    arguments += ["--output", output.string]
    return [
      .buildCommand(
        displayName: "Run SwordCommand",
        executable: try context.tool(named: "SwordCommand").path,
        arguments: arguments,
        inputFiles: inputPaths,
        outputFiles: [output]
      )
    ]
  }
}

#endif
