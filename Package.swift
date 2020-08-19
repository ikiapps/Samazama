// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Samazama",
    products: [
        .library(
            name: "Samazama",
            targets: ["Samazama"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Samazama",
            dependencies: []),
        .testTarget(
            name: "SamazamaTests",
            dependencies: ["Samazama"]),
    ]
)
