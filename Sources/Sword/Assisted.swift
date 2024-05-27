import Foundation

@propertyWrapper
public struct Assisted<T> {
  public var wrappedValue: T
  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }
}
