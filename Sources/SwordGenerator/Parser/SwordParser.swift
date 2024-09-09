import Foundation
import SwiftParser
import SwiftSyntax
import SwordFoundation

public struct SwordParser {
  private let reporter: SwordReporter

  public init(reporter: SwordReporter) {
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

    let componentValidationResult = ComponentValidator(componentRegistry: componentRegistry)
      .validate()
    let dependencyValidationResult = DependencyValidator(dependencyRegistry: dependencyRegistry)
      .validate()
    let moduleValidationResult = ModuleValidator(moduleRegistry: moduleRegistry).validate()
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

    let bindingGraphFactory = BindingGraphFactory(
      subcomponentsByParent: subcomponentsByParent,
      dependenciesByComponentName: dependenciesByComponentName,
      modulesByComponentName: modulesByComponentName
    )
    let bindingGraph = bindingGraphFactory.makeBindingGraph(rootComponent: component)
    let bindingGraphValidationResult = BindingGraphValidator(bindingGraph: bindingGraph).validate()

    guard case .valid = bindingGraphValidationResult else {
      for report in bindingGraphValidationResult.reports {
        reporter.send(report)
      }
      exit(1)
    }

    return (
      bindingGraph,
      Array(importRegistry.imports)
    )
  }
}
