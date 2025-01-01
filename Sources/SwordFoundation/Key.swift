import Foundation

package struct Key: Hashable, Codable {
  package let value: String

  package init(type: Type) {
    self.value =
      type.value
      .replacingOccurrences(of: ".", with: "")
      .firstWordLowercased
  }
}

extension String {
  fileprivate var firstWordLowercased: String {
    var consecutiveUppercaseCount = 0
    for char in self {
      if char.isUppercase {
        consecutiveUppercaseCount += 1
      } else {
        break
      }
    }
    let consecutiveLowercasedCount =
      if consecutiveUppercaseCount >= 2 {
        consecutiveUppercaseCount - 1
      } else {
        consecutiveUppercaseCount
      }
    return self.prefix(consecutiveLowercasedCount).lowercased()
      + self.dropFirst(consecutiveLowercasedCount)
  }
}
