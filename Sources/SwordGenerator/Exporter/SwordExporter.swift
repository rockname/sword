import Foundation
import SwiftSyntax

public struct SwordExporter {
  private let renderer: SwordRenderer

  public init(renderer: SwordRenderer) {
    self.renderer = renderer
  }

  func export(
    bindingGraph: BindingGraph,
    imports: [Import],
    outputPath: URL
  ) throws {
    let output = renderer.render(
      bindingGraph: bindingGraph,
      imports: imports
    )
    guard let data = output.data(using: .utf8) else {
      return
    }

    try data.write(to: outputPath, options: .atomic)
  }
}
