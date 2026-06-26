// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MGRS",
    platforms: [.macOS(.v11), .iOS(.v13)],
    products: [
        .library(
            name: "MGRS",
            targets: ["MGRS"])
    ],
    dependencies: [
        .package(url: "https://github.com/ngageoint/grid-ios", from: "2.0.0"),
        .package(url: "https://github.com/ngageoint/simple-features-ios", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "MGRS",
            dependencies: [
                .product(name: "Grid", package: "grid-ios"),
                .product(name: "SimpleFeatures", package: "simple-features-ios")
            ],
            path: "mgrs-ios",
            resources: [
                .copy("mgrs.plist"),
            ]
        ),
        .testTarget(
            name: "MGRSTests",
            dependencies: [
                "MGRS"
            ],
            path: "mgrs-iosTests"
        )
    ]
)
