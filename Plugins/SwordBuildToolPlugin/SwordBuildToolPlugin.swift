import Foundation
import PackagePlugin

@main
struct SwordBuildToolPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    let dependencies = recursiveSamePackageDependencies(for: target).removingDuplicates(by: \.id)
    let targetByName = Dictionary(dependencies.map { ($0.name, $0) }, uniquingKeysWith: { (first, _) in first })

    let inputDirectories = dependencies.compactMap { dependency in
      dependency.directory.string.replacingOccurrences(
        of: context.package.directoryURL.path(),
        with: ""
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

  private func recursiveSamePackageDependencies(for target: Target) -> [Target] {
    guard
      let sourceModule = target.sourceModule,
      case .generic = sourceModule.kind
    else { return [] }

    return sourceModule.dependencies.reduce([target]) { partialResult, dependency in
      switch dependency {
      case .target(let dependencyTarget):
        partialResult + recursiveSamePackageDependencies(for: dependencyTarget)
      case .product: partialResult
      @unknown default: partialResult
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

private extension Sequence {
  func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    var seen = Set<T>()
    return filter { seen.insert($0[keyPath: keyPath]).inserted }
  }
}
