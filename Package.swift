// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoodsKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "GoodsKit", targets: ["GoodsKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "GoodsKit",
            dependencies: [],
            resources: [
                .process("Resources")
            ]),
        .executableTarget(
            name: "GoodsKitCLI",
            dependencies: [
                "GoodsKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "GoodsKitTests",
            dependencies: ["GoodsKit"],
            resources: [
                .copy("Resources")
            ]),
    ]
)
