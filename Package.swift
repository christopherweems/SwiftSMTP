// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSMTP",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftSMTP",
            targets: ["SwiftSMTP"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.25.1"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.10.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftSMTP",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
            ]),
        .target(
            name: "SwiftSMTPCLI",
            dependencies: [
                "SwiftSMTP",
                .product(name: "NIO", package: "swift-nio"),
            ]),
        .testTarget(
            name: "SwiftSMTPTests",
            dependencies: ["SwiftSMTP"]),
    ]
)
