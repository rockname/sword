import Foundation

public final class InstanceStore {
  private let singleLock = NSRecursiveLock()
  private let weakReferenceLock = NSRecursiveLock()

  private var singleInstances = [String: AnyObject]()
  private var weakReferenceInstances = NSMapTable<NSString, AnyObject>(
    keyOptions: .copyIn,
    valueOptions: .weakMemory
  )

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

  public func withWeakReference<T: AnyObject>(_ function: String, _ factory: () -> T) -> T {
    weakReferenceLock.lock()
    defer {
      weakReferenceLock.unlock()
    }

    if let instance = (weakReferenceInstances.object(forKey: function as NSString) as? T?) ?? nil {
      return instance
    }
    let instance = factory()
    weakReferenceInstances.setObject(instance, forKey: function as NSString)

    return instance
  }
}
