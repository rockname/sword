import ArgumentParser
import Foundation
import PathKit
import SwiftParser
import SwiftSyntax
import SwordGenerator
import Yams

@main
struct SwordCommand: AsyncParsableCommand {
  @Option(parsing: .upToNextOption)
  var targets: [String] = []
  @Option(parsing: .upToNextOption)
  var inputs: [String] = []
  @Option
  var output: String

  mutating func run() async throws {
    try loadLocalPackagesIfNeeded()

    // Parse files in current working directory if no inputs were specified.
    let allInputs = inputs.isEmpty ? ["."] : inputs
    let sourceFilePaths = try allInputs.flatMap { input -> [URL] in
      let path = Path(input)
      return if path.isFile {
        [path.absolute().url]
      } else {
        try path.recursiveChildren().compactMap { child in
          guard child.extension == "swift" else { return nil }

          return child.absolute().url
        }
      }
    }
    let sourceFiles = try sourceFilePaths.map { sourceFilePath in
      let source = try String(contentsOf: sourceFilePath, encoding: .utf8)
      return SourceFile(
        path: sourceFilePath.path(),
        tree: Parser.parse(source: source)
      )
    }

    let parser = SwordParser()
    let reporter = SwordReporter(fileUpdater: .standardOutput)
    let renderer = SwordRenderer()
    let exporter = SwordExporter(renderer: renderer)
    let generator = SwordGenerator(
      parser: parser,
      reporter: reporter,
      exporter: exporter
    )
    try await generator.generate(
      sourceFiles: sourceFiles,
      targets: targets,
      output: output
    )
  }

  mutating private func loadLocalPackagesIfNeeded() throws {
    let configurationPath = Path.current + ".sword.yml"
    guard configurationPath.exists else { return }

    let data = try configurationPath.read()
    let configuration = try YAMLDecoder().decode(Configuration.self, from: data)

    for localPackage in configuration.localPackages {
      targets.append(contentsOf: localPackage.targets)

      let sourcesPath = Path.current + localPackage.path + "Sources"
      for swiftFile in sourcesPath.glob("**/*.swift") {
        inputs.append(swiftFile.string)
      }
    }
  }
}
