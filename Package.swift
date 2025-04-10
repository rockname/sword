// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "sword",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "Sword", targets: ["Sword"]),
    .plugin(name: "SwordBuildToolPlugin", targets: ["SwordBuildToolPlugin"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-syntax.git",
      exact: "600.0.1"
    ),
    .package(
      url: "https://github.com/apple/swift-argument-parser",
      from: "1.3.0"
    ),
    .package(
      url: "https://github.com/jpsim/Yams.git",
      from: "5.1.2"
    ),
    .package(
      url: "https://github.com/davecom/SwiftGraph",
      from: "3.1.0"
    ),
    .package(
      url: "https://github.com/kylef/PathKit.git",
      exact: "1.0.1"
    ),
  ],
  targets: [
    .target(
      name: "SwiftSyntaxSupport",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax")
      ]
    ),
    .target(
      name: "SwordFoundation"
    ),
    .target(
      name: "SwordComponentArgument",
      dependencies: [
        "SwordFoundation",
        .product(name: "SwiftSyntax", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "SwordGenerator",
      dependencies: [
        "SwordFoundation",
        "SwordComponentArgument",
        "SwiftSyntaxSupport",
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftGraph", package: "SwiftGraph"),
      ]
    ),
    .executableTarget(
      name: "SwordCommand",
      dependencies: [
        "SwordGenerator",
        "PathKit",
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Yams", package: "Yams"),
      ]
    ),
    .plugin(
      name: "SwordBuildToolPlugin",
      capability: .buildTool(),
      dependencies: [
        .target(name: "SwordCommand")
      ]
    ),
    .macro(
      name: "SwordMacros",
      dependencies: [
        "SwordComponentArgument",
        "SwiftSyntaxSupport",
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "SwordMacrosTests",
      dependencies: [
        "SwordMacros",
        "SwordComponentArgument",
        "SwiftSyntaxSupport",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "Sword",
      dependencies: [
        "SwordFoundation",
        "SwordMacros",
      ]
    ),
  ]
)
