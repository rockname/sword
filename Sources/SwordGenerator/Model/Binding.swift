import Foundation
import SwiftSyntax
import SwordComponentArgument
import SwordFoundation

struct Binding {
  let key: Key
  let type: Type
  let bindingRequests: [BindingRequest]
  let location: SourceLocation

  init(componentArgument: ComponentArgument) {
    self.key = Key(type: componentArgument.type)
    self.type = componentArgument.type
    self.bindingRequests = []
    self.location = componentArgument.location
  }

  init(registration: Registration) {
    self.key = registration.key
    self.type = registration.type
    self.bindingRequests = registration.parameters
      .filter { !$0.isAssisted }
      .map {
        BindingRequest(
          key: $0.key,
          type: $0.type,
          location: $0.location
        )
      }
    self.location = registration.location
  }
}

struct BindingRequest: Hashable {
  let key: Key
  let type: Type
  let location: SourceLocation
}
