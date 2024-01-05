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
            url: "https://bwlivefronttest.blob.core.windows.net/sdk/816799d-BitwardenFFI.xcframework.zip",
            checksum: "c9eeecf89703b3304a08d020d4b3ecc8271574a6c0d2d4f49da585b2ea2743c1"),
        .testTarget(
            name: "BitwardenSdkTests",
            dependencies: ["BitwardenSdk"])
    ]
)
