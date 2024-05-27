import Foundation

public final class InstanceStore {
  private let singleLock = NSRecursiveLock()

  private var singleInstances = [String: AnyObject]()

  public init() {}

  public func withSingle<T: AnyObject>(_ function: String, _ factory: () -> T) -> T {
    singleLock.lock()
    defer {
      singleLock.unlock()
    }

    if let instance = (singleInstances[function] as? T?) ?? nil {
      return instance
    }
    let instance = factory()
    singleInstances[function] = instance

    return instance
  }
}
