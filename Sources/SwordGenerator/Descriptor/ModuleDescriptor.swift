import Foundation

struct ModuleDescriptor: Hashable {
  let name: String
  let componentName: ComponentName
  let providers: [ProviderDescriptor]
}
