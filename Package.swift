// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Clippy",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Clippy",
            path: "Sources/Clippy",
            resources: [
                .copy("../../Resources/Info.plist")
            ]
        )
    ]
)
