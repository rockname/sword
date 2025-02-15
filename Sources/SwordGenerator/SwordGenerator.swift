import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

package struct SwordGenerator {
  private let parser: SwordParser
  private let exporter: SwordExporter

  package init(parser: SwordParser, exporter: SwordExporter) {
    self.parser = parser
    self.exporter = exporter
  }

  package func generate(
    sourceFiles: [SourceFile],
    targets: [String],
    output: String
  ) throws {
    let (bindingGraph, imports) = try parser.parse(sourceFiles: sourceFiles, targets: targets)
    try Logging.recordInterval(name: "exportBindingGraph") {
      try exporter.export(
        bindingGraph: bindingGraph,
        imports: imports,
        outputPath: URL(filePath: output)
      )
    }
  }
}
