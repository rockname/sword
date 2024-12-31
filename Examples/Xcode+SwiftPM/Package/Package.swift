// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Package",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "ComponentApp",
      targets: ["ComponentApp"]
    ),
    .library(
      name: "AudioRecorder",
      targets: ["AudioRecorder"]
    ),
  ],
  dependencies: [
    .package(name: "sword", path: "../../../")
  ],
  targets: [
    .target(
      name: "ComponentApp",
      dependencies: [
        .product(name: "Sword", package: "sword")
      ]
    ),
    .target(
      name: "AudioRecorder",
      dependencies: [
        "ComponentApp",
        .product(name: "Sword", package: "sword"),
      ]
    ),
  ]
)
