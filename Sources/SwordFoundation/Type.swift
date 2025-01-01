import Foundation

package struct Type: Hashable, Codable {
  package let value: String

  package init(value: String) {
    self.value = value
  }
}
