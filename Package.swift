// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "qattahpay-ios-sdk",
    products: [
        .library(name: "qattahpay-ios-sdk", targets: ["qattahpay-ios-sdk"])
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "15.0.0"))
    ],
    targets: [
        .target(name: "qattahpay-ios-sdk", dependencies: ["SocketIO"], path: "Sources")
    ]
)
