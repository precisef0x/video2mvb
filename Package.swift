// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "video2mvb",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(
            name: "video2mvb",
            targets: ["video2mvb"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "video2mvb",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "./Sources",
            swiftSettings: [
                .unsafeFlags(["-O"], .when(configuration: .release))
            ]
        ),
    ]
)
