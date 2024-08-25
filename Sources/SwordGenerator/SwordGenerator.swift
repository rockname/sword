import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

public struct SwordGenerator {
  private let parser: SwordParser
  private let exporter: SwordExporter

  public init(parser: SwordParser, exporter: SwordExporter) {
    self.parser = parser
    self.exporter = exporter
  }

  public func generate(
    sourceFiles: [SourceFile],
    targets: [String],
    output: String
  ) throws {
    let (bindingGraph, imports) = try parser.parse(sourceFiles: sourceFiles, targets: targets)
    try exporter.export(
      bindingGraph: bindingGraph,
      imports: imports,
      outputPath: URL(filePath: output)
    )
  }
}
