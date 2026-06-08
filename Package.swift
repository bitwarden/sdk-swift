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
            targets: ["BitwardenSdk", "BitwardenFFI"]),
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
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]),
        .testTarget(
            name: "BitwardenSdkTests",
            dependencies: ["BitwardenSdk"]),
        .binaryTarget(
  name: "BitwardenFFI",
  url: "https://github.com/bitwarden/sdk-swift/releases/download/v3.0.0-6600-c095c30/BitwardenFFI-3.0.0-c095c30.xcframework.zip",
  checksum: "ceb17cf78be7bb5dcfd49db5aa5ac2250428df8a90a0ad8583ab234a1fb23ae8")
    ]
)
