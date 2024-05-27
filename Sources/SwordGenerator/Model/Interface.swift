import Foundation
import SwordFoundation

struct Interface {
  let value: String

  func asType() -> Type {
    Type(value: value)
  }
}
