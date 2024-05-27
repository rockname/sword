import Foundation

final class ModuleRegistry {
  private(set) var descriptorsByComponentName = [ComponentName: [ModuleDescriptor]]()

  func modules(for componentName: ComponentName) -> [ModuleDescriptor] {
    descriptorsByComponentName[componentName] ?? []
  }

  func register(_ descriptor: ModuleDescriptor, by componentName: ComponentName) {
    descriptorsByComponentName[componentName, default: []].append(descriptor)
  }
}
