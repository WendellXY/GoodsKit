// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuperGoodsProcessor",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "SuperGoodsProcessor", targets: ["SuperGoodsProcessor"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SuperGoodsProcessor",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            resources: [
                .process("Resources")
            ]),
        .executableTarget(
            name: "SuperGoodsProcessorCLI",
            dependencies: [
                "SuperGoodsProcessor",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]),
        .testTarget(
            name: "SuperGoodsProcessorTests",
            dependencies: ["SuperGoodsProcessor"],
            resources: [
                .copy("Resources")
            ]),
    ]
)
