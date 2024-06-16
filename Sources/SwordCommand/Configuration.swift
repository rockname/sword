import Foundation

struct Configuration: Codable {
  struct LocalPackage: Codable {
    let path: String
    let targets: [String]
  }

  let localPackages: [LocalPackage]

  private enum CodingKeys: String, CodingKey {
    case localPackages = "local_packages"
  }
}
