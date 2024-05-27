import Foundation

struct Todo: Identifiable {
  struct ID: Hashable {
    let value: String
  }

  let id: ID
  let title: String
  let hasDone: Bool
}
