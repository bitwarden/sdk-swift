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
        .binaryTarget(
            name: "BitwardenFFI",
            url: "https://bwlivefronttest.blob.core.windows.net/sdk/dfdbf7d-BitwardenFFI.xcframework.zip",
            checksum: "6ec71db8879e53f3a22cb68822d416e72f306b28bfda26c8c49777afd96334eb"),
        .testTarget(
            name: "BitwardenSdkTests",
            dependencies: ["BitwardenSdk"])
    ]
)
