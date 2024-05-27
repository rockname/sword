import Foundation
import SwordFoundation

struct ResolvedBindings {
  let key: Key
  let bindings: [Binding]
}

final class Resolver {
  private let bindingsByKey: [Key: [Binding]]
  private let parentResolver: Resolver?

  init(
    bindingsByKey: [Key: [Binding]],
    parentResolver: Resolver?
  ) {
    self.bindingsByKey = bindingsByKey
    self.parentResolver = parentResolver
  }

  func resolve() -> [BindingRequest: ResolvedBindings] {
    var resolvedBindingsByRequest = [BindingRequest: ResolvedBindings]()
    let bindingRequests = bindingsByKey.values.flatMap { $0.flatMap(\.bindingRequests) }
    for request in bindingRequests {
      resolvedBindingsByRequest[request] = resolve(request)
    }
    return resolvedBindingsByRequest
  }

  private func resolve(_ request: BindingRequest) -> ResolvedBindings {
    let currentResolvingBindings = bindingsByKey[request.key] ?? []
    if let parentResolver {
      let parentResolvedBindings = parentResolver.resolve(request)
      let resolvedBindings = ResolvedBindings(
        key: request.key,
        bindings: parentResolvedBindings.bindings + currentResolvingBindings
      )
      return resolvedBindings
    } else {
      let resolvedBindings = ResolvedBindings(
        key: request.key,
        bindings: currentResolvingBindings
      )
      return resolvedBindings
    }
  }
}
