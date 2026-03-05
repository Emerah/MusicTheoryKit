// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MusicTheoryKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "MusicTheoryKit",
            targets: ["MusicTheoryKit"]
        ),
    ],
    targets: [
        .target(name: "MusicTheoryKit"),
        .testTarget(
            name: "MusicTheoryKitTests",
            dependencies: ["MusicTheoryKit"]
        ),
    ]
)
