import Foundation

struct Import: Hashable {
  let path: String
  let kind: String?

  init(
    path: String,
    kind: String? = nil
  ) {
    self.path = path
    self.kind = kind
  }
}
