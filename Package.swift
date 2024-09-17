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
            url: "https://github.com/bitwarden/sdk-swift/releases/download/v0.5.0-unstable-c57e3a7/BitwardenFFI-0.5.0-c57e3a7.xcframework.zip",
            checksum: "325fbbaf5e9c5fea6b006ec0db5168783eae059f5b178c27fc137267595f2a35"
        ),
    ]
)
