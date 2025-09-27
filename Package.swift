// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZPTooltip",
    platforms: [
      // Namespace available since iOS 14.
      // coordinateSpace modifier available since iOS 17
      .iOS(.v17), .macOS(.v15)
    ],
    products: [
        .library(
            name: "ZPTooltip",
            targets: ["ZPTooltip"]
        ),
    ],
    targets: [
        .target(
            name: "ZPTooltip"
        ),
        .testTarget(
            name: "ZPTooltipTests",
            dependencies: [
              "ZPTooltip"
            ]
        )
    ]
)
