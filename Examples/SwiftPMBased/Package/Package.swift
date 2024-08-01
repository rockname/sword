// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "Package",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "MainScene",
      targets: ["MainScene"]
    ),
    .library(
      name: "UIOnboarding",
      targets: ["UIOnboarding"]
    ),
    .library(
      name: "UIRegistration",
      targets: ["UIRegistration"]
    ),
    .library(
      name: "UIHome",
      targets: ["UIHome"]
    ),
    .library(
      name: "UIPostDetail",
      targets: ["UIPostDetail"]
    ),
  ],
  dependencies: [
    .package(name: "sword", path: "../../../")
  ],
  targets: [
    .target(
      name: "DataModel"
    ),
    .target(
      name: "ComponentApp",
      dependencies: [
        "DataModel",
        .product(name: "Sword", package: "sword"),
      ]
    ),
    .target(
      name: "ComponentUser",
      dependencies: [
        "ComponentApp",
        .product(name: "Sword", package: "sword"),
      ]
    ),
    .target(
      name: "DataAPIClient",
      dependencies: [
        "DataModel"
      ]
    ),
    .target(
      name: "DataAPIClientDefault",
      dependencies: [
        "ComponentApp",
        "DataAPIClient",
        .product(name: "Sword", package: "sword"),
      ]
    ),
    .target(
      name: "DataRepository",
      dependencies: [
        "ComponentUser",
        "DataModel",
        "DataAPIClient",
      ]
    ),
    .target(
      name: "CommonUI"
    ),
    .target(
      name: "UILaunch"
    ),
    .target(
      name: "UIOnboarding",
      dependencies: [
        "DataRepository",
        "CommonUI",
        "UIRegistration",
      ]
    ),
    .target(
      name: "UIRegistration",
      dependencies: [
        "DataRepository",
        "CommonUI",
        .product(name: "Sword", package: "sword"),
      ]
    ),
    .target(
      name: "UIHome",
      dependencies: [
        "ComponentUser",
        "DataRepository",
        .product(name: "Sword", package: "sword"),
      ]
    ),
    .target(
      name: "UIPostDetail",
      dependencies: [
        "ComponentUser",
        "DataModel",
        "DataRepository",
        .product(name: "Sword", package: "sword"),
      ]
    ),
    .target(
      name: "MainScene",
      dependencies: [
        "ComponentApp",
        "ComponentUser",
        "DataModel",
        "DataAPIClientDefault",
        "DataRepository",
        "UILaunch",
        "UIOnboarding",
        "UIRegistration",
        "UIHome",
        "UIPostDetail",
        .product(name: "Sword", package: "sword"),
      ],
      plugins: [
        .plugin(name: "SwordBuildToolPlugin", package: "sword")
      ]
    ),
  ]
)
