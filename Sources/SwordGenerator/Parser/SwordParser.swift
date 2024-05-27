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
  ) throws -> (ComponentTree, [Import]) {
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
      case .valid((let componentNode, let subcomponentsByParent)) = componentValidationResult,
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

    let componentTreeFactory = ComponentTreeFactory(
      subcomponentsByParent: subcomponentsByParent,
      dependenciesByComponentName: dependenciesByComponentName,
      modulesByComponentName: modulesByComponentName
    )
    let componentTree = componentTreeFactory.makeComponentTree(componentNode: componentNode)

    let componentTreeValidationResult = ComponentTreeValidator(componentTree: componentTree)
      .validate()
    guard case .valid = componentTreeValidationResult else {
      for report in componentTreeValidationResult.reports {
        reporter.send(report)
      }
      exit(1)
    }

    return (
      componentTree,
      Array(importRegistry.imports)
    )
  }
}
