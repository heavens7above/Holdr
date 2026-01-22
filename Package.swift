// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Holdr",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Holdr", targets: ["Holdr"])
    ],
    targets: [
        .executableTarget(
            name: "Holdr",
            dependencies: [],
            path: "Sources/Holdr",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "HoldrTests",
            dependencies: ["Holdr"]
        )
    ]
)
