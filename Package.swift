// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "WindowKit",
  platforms: [.macOS(.v14)],
  products: [
    .library(
      name: "WindowKit",
      targets: ["WindowKit"]
    ),
    .library(
      name: "WindowKitAppKit",
      targets: ["WindowKitAppKit"]
    ),
  ],
  targets: [
    .target(
      name: "WindowKit"
    ),
    .target(
      name: "WindowKitAppKit",
      dependencies: [
        "WindowKit"
      ]
    ),
    .testTarget(
      name: "WindowKitTests",
      dependencies: ["WindowKit"]
    ),
    .testTarget(
      name: "WindowKitAppKitTests",
      dependencies: [
        "WindowKitAppKit",
        "WindowKit",
      ]
    ),
  ]
)
