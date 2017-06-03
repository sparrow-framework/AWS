// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "AWS",
    dependencies: [
        .Package(url: "https://github.com/Zewo/Zewo.git", majorVersion: 0, minor: 13),
    ]
)
