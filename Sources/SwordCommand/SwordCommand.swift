import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax
import SwordGenerator
import Yams

@main
struct SwordCommand: ParsableCommand {
  @Option(parsing: .upToNextOption)
  var targets: [String] = []
  @Option(parsing: .upToNextOption)
  var inputs: [String] = []
  @Option
  var output: String

  mutating func run() throws {
    try loadLocalPackagesIfNeeded()

    let sourceFiles = try inputs.map { path in
      let url = URL(filePath: path)
      let source = try String(contentsOf: url)
      return SourceFile(
        path: url.path(),
        tree: Parser.parse(source: source)
      )
    }
    let reporter = SwordReporter(fileUpdater: .standardOutput)
    let parser = SwordParser(reporter: reporter)
    let renderer = SwordRenderer()
    let exporter = SwordExporter(renderer: renderer)
    let generator = SwordGenerator(
      parser: parser,
      exporter: exporter
    )
    try generator.generate(
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
}
