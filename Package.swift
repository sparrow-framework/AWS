// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "AWS",
    products: [
        .library(
            name: "AWS",
            targets: [
               "AWS"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Zewo/Zewo.git", .branch("swift-4"))
    ],
    targets: [
        .target(name: "AWS", dependencies: ["Zewo"]),
        .testTarget(name: "AWSTests", dependencies: ["AWS"]),
    ]
)


