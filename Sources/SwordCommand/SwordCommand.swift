import ArgumentParser
import Foundation
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
    let allInputs = inputs.isEmpty ? [""] : inputs
    let sourceFiles = try allInputs.flatMap { input in
      paths(in: input)
    }
    .map { url in
      let source = try String(contentsOf: url)
      return SourceFile(
        path: url.path(),
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
    let fileManager = FileManager.default
    let configurationFilePath = URL(filePath: fileManager.currentDirectoryPath).appending(path: ".sword.yml")

    guard fileManager.fileExists(atPath: configurationFilePath.path()) else { return }

    let data = try Data(contentsOf: configurationFilePath)
    let configuration = try YAMLDecoder().decode(Configuration.self, from: data)

    for localPackage in configuration.localPackages {
      targets.append(contentsOf: localPackage.targets)

      let inputPath = URL(filePath: fileManager.currentDirectoryPath)
        .appending(path: localPackage.path)
        .appending(path: "Sources")
      if let enumerator = fileManager.enumerator(atPath: inputPath.path()) {
        for case let filePath as String in enumerator {
          if filePath.hasSuffix(".swift") {
            let fullFilePath = inputPath.appending(path: filePath)
            inputs.append(fullFilePath.path())
          }
        }
      }
    }
  }

  private func paths(in path: String) -> [URL] {
    if path.isFile {
      return [URL(filePath: path)]
    }

    let fileManager = FileManager.default
    let absolutePath = URL(filePath: fileManager.currentDirectoryPath).appending(path: path)
    return fileManager.subpaths(atPath: absolutePath.path())?.compactMap { element -> URL? in
      guard element.hasSuffix(".swift") else { return nil }

      let elementAbsolutePath = absolutePath.appending(path: element)
      return elementAbsolutePath.path().isFile ? elementAbsolutePath : nil
    } ?? []
  }
}
