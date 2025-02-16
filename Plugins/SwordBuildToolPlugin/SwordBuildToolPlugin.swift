import Foundation
import PackagePlugin

@main
struct SwordBuildToolPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    guard let sourceModule = target.sourceModule else { return [] }

    let targets = transitiveTargets(for: sourceModule)
    let targetByName = Dictionary(targets.map { ($0.name, $0) }, uniquingKeysWith: { (first, _) in first })
    let targetSourceModules = targetByName.values.compactMap(\.sourceModule)
    let inputDirectories = ([sourceModule] + targetSourceModules).compactMap { sourceModule in
      relativePath(
        from: context.package.directoryURL,
        to: URL(fileURLWithPath: sourceModule.directory.string, isDirectory: true).standardized
      )
    }
    let output = context.pluginWorkDirectoryURL.appending(path: "Sword.generated.swift")
    var arguments = [String]()
    let targetNames = targetByName.keys
    if !targetNames.isEmpty {
      arguments += ["--targets"] + targetNames
    }
    if !inputDirectories.isEmpty {
      arguments += ["--inputs"] + inputDirectories
    }
    arguments += ["--output", output.relativePath]
    return [
      .buildCommand(
        displayName: "Run SwordCommand",
        executable: try context.tool(named: "SwordCommand").url,
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

  private func relativePath(from baseURL: URL, to absoluteURL: URL) -> String? {
    guard absoluteURL.path.hasPrefix(baseURL.path) else { return nil }

    var relative = absoluteURL.path.replacingOccurrences(of: baseURL.path, with: "")
    if relative.hasPrefix("/") {
      relative.removeFirst()
    }

    return relative
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
    let inputURLs = ([target] + frameworkTargets).flatMap { target -> [URL] in
      target.inputFiles
        .filter { $0.type == .source && $0.url.pathExtension == "swift" }
        .map { $0.url }
    }
    let output = context.pluginWorkDirectoryURL.appending(path: "Sword.generated.swift")
    var arguments = [String]()
    if !frameworkTargets.isEmpty {
      arguments += ["--targets"] + frameworkTargets.map(\.displayName)
    }
    if !inputURLs.isEmpty {
      arguments += ["--inputs"] + inputURLs.map(\.relativePath)
    }
    arguments += ["--output", output.relativePath]
    return [
      .buildCommand(
        displayName: "Run SwordCommand",
        executable: try context.tool(named: "SwordCommand").url,
        arguments: arguments,
        inputFiles: inputURLs,
        outputFiles: [output]
      )
    ]
  }
}

#endif
