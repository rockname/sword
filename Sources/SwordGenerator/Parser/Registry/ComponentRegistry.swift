import Foundation

final class ComponentRegistry {
  private(set) var components = [RootComponentDescriptor]()
  private(set) var subcomponentsByParent = [ComponentName: [SubcomponentDescriptor]]()

  func register(_ rootComponent: RootComponentDescriptor) {
    components.append(rootComponent)
  }

  func register(_ subcomponent: SubcomponentDescriptor, by parent: ComponentName) {
    subcomponentsByParent[parent, default: []].append(subcomponent)
  }
}
