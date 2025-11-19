// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NoteTagger",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "notetagger",
            targets: ["NoteTagger"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "NoteTagger",
            path: "Sources"
        )
    ]
)
