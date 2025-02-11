import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

package struct SwordGenerator {
  private let parser: SwordParser
  private let reporter: SwordReporter
  private let exporter: SwordExporter

  package init(
    parser: SwordParser,
    reporter: SwordReporter,
    exporter: SwordExporter
  ) {
    self.parser = parser
    self.reporter = reporter
    self.exporter = exporter
  }

  package func generate(
    sourceFiles: [SourceFile],
    targets: [String],
    output: String
  ) async throws {
    let parserResult = await Logging.recordInterval(name: "parseSourceFiles") {
      await parser.parse(sourceFiles)
    }

    async let componentTreeFactoryResult = Logging.recordInterval(name: "makeComponentTree") {
      await ComponentTreeFactory(
        rootComponentDescriptors: parserResult.rootComponentDescriptors,
        subcomponentDescriptors: parserResult.subcomponentDescriptors
      ).make()
    }
    async let dependenciesFactoryResult = Logging.recordInterval(name: "makeDependencies") {
      await DependenciesFactory(dependencyDescriptors: parserResult.dependencyDescriptors).make()
    }
    async let moduleFactoryResult = Logging.recordInterval(name: "makeModules") {
      await ModulesFactory(moduleDescriptors: parserResult.moduleDescriptors).make()
    }
    guard
      case .success(let componentTree) = await componentTreeFactoryResult,
      case .success(let dependencies) = await dependenciesFactoryResult,
      case .success(let modules) = await moduleFactoryResult
    else {
      let reports =
        await componentTreeFactoryResult.reports + dependenciesFactoryResult.reports + moduleFactoryResult.reports
      for report in reports {
        reporter.send(report)
      }
      exit(1)
    }

    let bindingGraphFactoryResult = await Logging.recordInterval(name: "makeBindingGraph") {
      await BindingGraphFactory(
        componentTree: componentTree,
        dependencies: dependencies,
        modules: modules
      ).make()
    }
    guard case .success(let bindingGraph) = bindingGraphFactoryResult else {
      for report in bindingGraphFactoryResult.reports {
        reporter.send(report)
      }
      exit(1)
    }

    var imports = Set<Import>()
    let targetImports = targets.map { Import(path: $0) }
    for `import` in (parserResult.imports + targetImports) {
      imports.insert(`import`)
    }

    try Logging.recordInterval(name: "exportBindingGraph") {
      try exporter.export(
        bindingGraph: bindingGraph,
        imports: Array(imports),
        outputPath: URL(filePath: output)
      )
    }
  }
}
