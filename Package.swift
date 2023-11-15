// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUINavController",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SwiftUINavController",
            targets: ["SwiftUINavController", "NavigationControllerDelegateProxy"])
    ],
    targets: [
        .target(
            name: "SwiftUINavController",
            dependencies: ["NavigationControllerDelegateProxy"]),
        .target(
            name: "NavigationControllerDelegateProxy",
            publicHeadersPath: "include"),
        .testTarget(
            name: "SwiftUINavControllerTests",
            dependencies: ["SwiftUINavController"]),
    ]
)
