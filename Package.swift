// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "StatsdClient",
    products: [
        .library(
            name: "StatsdClient",
            targets: ["StatsdClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "StatsdClient",
            dependencies: [
                "NIO",
                "NIOConcurrencyHelpers",
            ]
        ),
        .testTarget(
            name: "StatsdClientTests",
            dependencies: ["StatsdClient"]
        ),
        .target(
            name: "statsd-client-example",
            dependencies: [
                .target(name: "StatsdClient"),
            ]
        ),
    ]
)
