// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitwardenSdk",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitwardenSdk",
            targets: ["BitwardenSdk", "BitwardenFFI"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BitwardenSdk",
            dependencies: ["BitwardenFFI"],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "BitwardenSdkTests",
            dependencies: ["BitwardenSdk"]
        ),
        .binaryTarget(
            name: "BitwardenFFI",
            url: "https://github.com/bitwarden/sdk-swift/releases/download/v1.0.0-unstable-6008e90/BitwardenFFI-1.0.0-6008e90.xcframework.zip",
            checksum: "eb41f9700d714d1d3a036a5dd77f4422a3eecbe7f4d0ceeb885472289f82a019"
        ),
    ]
)
