// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZPTooltip",
    platforms: [
      // Namespace available since iOS 14.
      // coordinateSpace modifier available since iOS 17
      .iOS(.v17), .mac(.v15)
    ],
    products: [
        .library(
            name: "ZPTooltip",
            targets: ["ZPTooltip"]
        ),
    ],
    dependencies: [
      .package(
        url: "https://github.com/pointfreeco/swift-snapshot-testing",
        from: "1.12.0"
      )
    ],
    targets: [
        .target(
            name: "ZPTooltip"
        ),
        .testTarget(
            name: "ZPTooltipTests",
            dependencies: [
              "ZPTooltip",
              .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: [
              "__Snapshots__"
            ]
        )
    ]
)
