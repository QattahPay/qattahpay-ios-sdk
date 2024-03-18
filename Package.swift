// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "qattahpay-ios-sdk",
    products: [
        .library(name: "qattahpay-ios-sdk", targets: ["qattahpay-ios-sdk"])
    ],
    dependencies: [],
    targets: [
        .target(name: "qattahpay-ios-sdk", dependencies: [], path: "Sources")
    ]
)
