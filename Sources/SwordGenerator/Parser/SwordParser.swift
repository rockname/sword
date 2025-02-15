import Foundation
import SwiftParser
import SwiftSyntax
import SwordFoundation

package struct SwordParser {
  struct Result {
    var rootComponentDescriptors = [RootComponentDescriptor]()
    var subcomponentDescriptors = [SubcomponentDescriptor]()
    var dependencyDescriptors = [DependencyDescriptor]()
    var moduleDescriptors = [ModuleDescriptor]()
    var imports = [Import]()

    mutating func merge(_ result: Result) {
      rootComponentDescriptors += result.rootComponentDescriptors
      subcomponentDescriptors += result.subcomponentDescriptors
      dependencyDescriptors += result.dependencyDescriptors
      moduleDescriptors += result.moduleDescriptors
      imports += result.imports
    }
  }

  package init() {
  }

  func parse(_ sourceFiles: [SourceFile]) async -> Result {
    await withTaskGroup(of: Result.self) { group in
      for sourceFile in sourceFiles {
        group.addTask {
          parse(sourceFile)
        }
      }
      var parserResult = Result()
      for await result in group {
        parserResult.merge(result)
      }
      return parserResult
    }
  }

  private func parse(_ sourceFile: SourceFile) -> Result {
    Result(
      rootComponentDescriptors: ComponentVisitor(sourceFile: sourceFile).walk(),
      subcomponentDescriptors: SubcomponentVisitor(sourceFile: sourceFile).walk(),
      dependencyDescriptors: DependencyVisitor(sourceFile: sourceFile).walk(),
      moduleDescriptors: ModuleVisitor(sourceFile: sourceFile).walk(),
      imports: ImportVisitor(sourceFile: sourceFile).walk()
    )
  }
}
