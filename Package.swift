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
            url: "https://bwlivefronttest.blob.core.windows.net/sdk/3c16656-BitwardenFFI.xcframework.zip",
            checksum: "72f5db3c6afc1860091154db431d46c56a37ff786f754183dc27d7cf2a3a5856"),
        .testTarget(
            name: "BitwardenSdkTests",
            dependencies: ["BitwardenSdk"])
    ]
)
