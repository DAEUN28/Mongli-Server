// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Mongli-Server",
  dependencies: [
    .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.8.0"),
    .package(url: "https://github.com/IBM-Swift/SwiftKueryMySQL.git", from: "2.0.2"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0")
  ],
  targets: [
    .target(name: "Mongli-Server", dependencies: ["Kitura", "SwiftKueryMySQL", "HeliumLogger"]),
    .testTarget(name: "Mongli-ServerTests" , dependencies: [.target(name: "Mongli-Server"), "Kitura" ])
  ]
)
