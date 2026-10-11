// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-integer",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Integer", targets: ["Integer"]),

        .library(name: "Integer Foundation Integration", targets: ["Integer Foundation Integration"]),
        .library(name: "Integer Test Support", targets: ["Integer Test Support"]),
    ],
    dependencies: [.package(url: "https://github.com/swift-atoms/swift-rounding.git", branch: "main")],
    targets: [
        .target(name: "Integer", dependencies: [.product(name: "Rounding", package: "swift-rounding")], path: "Sources/Integer"),
        .target(name: "Integer Foundation Integration", dependencies: [.target(name: "Integer")], path: "Sources/Integer Foundation Integration"),
        .target(name: "Integer Test Support", dependencies: [.target(name: "Integer")], path: "Tests/Support"),
        .testTarget(name: "Integer Tests", dependencies: [.target(name: "Integer"), .target(name: "Integer Test Support")], path: "Tests/Integer Tests"),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
