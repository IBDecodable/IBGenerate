// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IBGenerate",
    products: [
        .executable(
            name: "ibgenerate", targets: ["IBGenerate"]
        ),
        .library(
            name: "IBGenerateKit", targets: ["IBGenerateKit"]
        ),
        .library(
            name: "IBGenerateFrontend", targets: ["IBGenerateFrontend"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/IBDecodable/IBDecodable.git", .revision("HEAD")),
        .package(url: "https://github.com/IBDecodable/IBStoryboard.git", .revision("HEAD")),
        .package(url: "https://github.com/phimage/XcodeProjKit.git", .revision("2.0.0")),
        .package(url: "https://github.com/Carthage/Commandant.git", .upToNextMinor(from: "0.16.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMinor(from: "2.0.0")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from:"1.0.0"))
    ],
    targets: [
        .target(
            name: "IBGenerate",
            dependencies: ["IBGenerateKit", "IBGenerateFrontend"],
            path: "Sources/IBGenerate"
        ),
        .target(
            name: "IBGenerateKit",
            dependencies: ["Commandant", "IBDecodable", "Yams", "XcodeProjKit"],
            path: "Sources/IBGenerateKit"
        ),
        .target(
            name: "IBGenerateFrontend",
            dependencies: [ "IBGenerateKit", "PathKit"],
            path: "Sources/IBGenerateFrontend"
        ),
        .testTarget(
            name: "IBGenerateTests",
            dependencies: ["IBGenerate", "IBStoryboard", "IBGenerateKit"],
            path: "Tests"
        )
    ]
)
