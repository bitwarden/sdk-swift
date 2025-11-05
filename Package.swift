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
  url: "https://github.com/bitwarden/sdk-swift/releases/download/v1.0.0-2975-a3665fd/BitwardenFFI-1.0.0-a3665fd.xcframework.zip",
  checksum: "2b3e01f42c8f2ed7022b733d034d43a9bae894f7b4d195dd2c93f1756ae682d7")
    ]
)
