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
    let (componentTree, imports) = try parser.parse(sourceFiles: sourceFiles, targets: targets)
    try exporter.export(
      componentTree: componentTree,
      imports: imports,
      outputPath: URL(filePath: output)
    )
  }
}
