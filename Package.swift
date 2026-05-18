// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "WindowKit",
  platforms: [.macOS(.v12)],
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
  ],
  swiftLanguageVersions: [.v5]
)
