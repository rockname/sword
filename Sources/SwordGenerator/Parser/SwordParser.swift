import Foundation
import SwiftParser
import SwiftSyntax
import SwordFoundation

package struct SwordParser {
  private let reporter: SwordReporter

  package init(reporter: SwordReporter) {
    self.reporter = reporter
  }

  func parse(
    sourceFiles: [SourceFile],
    targets: [String]
  ) throws -> (BindingGraph, [Import]) {
    let componentRegistry = ComponentRegistry()
    let dependencyRegistry = DependencyRegistry()
    let moduleRegistry = ModuleRegistry()
    let importRegistry = ImportRegistry()

    Logging.recordInterval(name: "parseSourceFiles") {
      for sourceFile in sourceFiles {
        let visitors: [SyntaxVisitor] = [
          ComponentVisitor(
            componentRegistry: componentRegistry,
            sourceFile: sourceFile
          ),
          SubcomponentVisitor(
            componentRegistry: componentRegistry,
            sourceFile: sourceFile
          ),
          DependencyVisitor(
            dependencyRegistry: dependencyRegistry,
            sourceFile: sourceFile
          ),
          ModuleVisitor(
            moduleRegistry: moduleRegistry,
            sourceFile: sourceFile
          ),
          ImportVisitor(
            importRegistry: importRegistry,
            sourceFile: sourceFile
          ),
        ]
        for visitor in visitors {
          visitor.walk(sourceFile.tree)
        }
      }

      for target in targets {
        importRegistry.register(target)
      }
    }

    let componentValidationResult = Logging.recordInterval(name: "makeComponentTree") {
      ComponentValidator(componentRegistry: componentRegistry)
        .validate()
    }
    let dependencyValidationResult = Logging.recordInterval(name: "makeDependencies") {
      DependencyValidator(dependencyRegistry: dependencyRegistry)
        .validate()
    }
    let moduleValidationResult = Logging.recordInterval(name: "makeModules") {
      ModuleValidator(moduleRegistry: moduleRegistry).validate()
    }
    guard
      case .valid((let component, let subcomponentsByParent)) = componentValidationResult,
      case .valid(let dependenciesByComponentName) = dependencyValidationResult,
      case .valid(let modulesByComponentName) = moduleValidationResult
    else {
      let reports = [
        componentValidationResult.reports,
        dependencyValidationResult.reports,
        moduleValidationResult.reports,
      ].flatMap { $0 }
      for report in reports {
        reporter.send(report)
      }
      exit(1)
    }

    let bindingGraph = Logging.recordInterval(name: "makeBindingGraph") {
      let bindingGraphFactory = BindingGraphFactory(
        subcomponentsByParent: subcomponentsByParent,
        dependenciesByComponentName: dependenciesByComponentName,
        modulesByComponentName: modulesByComponentName
      )
      let bindingGraph = bindingGraphFactory.makeBindingGraph(rootComponent: component)
      let bindingGraphValidationResult = BindingGraphValidator(bindingGraph: bindingGraph)
        .validate()
      guard case .valid = bindingGraphValidationResult else {
        for report in bindingGraphValidationResult.reports {
          reporter.send(report)
        }
        exit(1)
      }

      return bindingGraph
    }

    return (
      bindingGraph,
      Array(importRegistry.imports)
    )
  }
}
