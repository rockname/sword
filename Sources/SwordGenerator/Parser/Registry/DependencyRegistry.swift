import Foundation

final class DependencyRegistry {
  private(set) var descriptorsByComponentName = [ComponentName: [DependencyDescriptor]]()

  func descriptors(for componentName: ComponentName) -> [DependencyDescriptor] {
    descriptorsByComponentName[componentName] ?? []
  }

  func register(_ descriptor: DependencyDescriptor, by componentName: ComponentName) {
    descriptorsByComponentName[componentName, default: []].append(descriptor)
  }
}
