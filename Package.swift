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

//let package = Package(
//    name: "qattahpay-ios-sdk",
//    products: [
//        // Products define the executables and libraries a package produces, and make them visible to other packages.
//        .library(name: "qattahpay-ios-sdk", targets: ["qattahpay-ios-sdk"]),
//    ],
//    dependencies: [
//        // Dependencies declare other packages that this package depends on.
//        // .package(url: /* package url */, from: "1.0.0"),
//        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "15.0.0"))
//    ],
//    targets: [
//        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
//        // Targets can depend on other targets in this package, and on products in packages this package depends on.
//        .target(name: "qattahpay-ios-sdk", dependencies: ["SocketIO"], path: "./Sources"),
//        .testTarget(name: "qattahpay-ios-sdkTests", dependencies: ["qattahpay-ios-sdk"]),
//    ]
//)
