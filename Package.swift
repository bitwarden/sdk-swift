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
            dependencies: ["BitwardenFFI", "BitwardenSdkSupport"],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]),
        .target(name: "BitwardenSdkSupport"),
        .testTarget(
            name: "BitwardenSdkTests",
            dependencies: ["BitwardenSdk"]),
        .binaryTarget(
  name: "BitwardenFFI",
  url: "https://github.com/bitwarden/sdk-swift/releases/download/v4.0.0-9185-d393869/BitwardenFFI-4.0.0-d393869.xcframework.zip",
  checksum: "c4a0e705caa420228000a565e8a0c7db919ee4eb0b0f9e1ac77172c38743e763")
    ]
)
