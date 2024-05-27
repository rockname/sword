import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax
import SwordGenerator

@main
struct SwordCommand: ParsableCommand {
  @Option(parsing: .upToNextOption)
  var targets: [String] = []
  @Option(parsing: .upToNextOption)
  var inputs: [String] = []
  @Option
  var output: String

  func run() throws {
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
}
