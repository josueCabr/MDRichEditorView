// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MDRichEditor",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "MDRichEditor",
            targets: ["MDRichEditor"]),
    ],
    dependencies: [
         .package(url:"https://github.com/josueCabr/RichEditorView.git", branch: "master"),
         .package(url: "https://github.com/JohnSundell/Ink.git", branch: "master")
    ],
    targets: [
        .target(
            name: "MDRichEditor",
            dependencies: [
                "RichEditorView",
                "Ink"
            ]),
        .testTarget(
            name: "MDRichEditorTests",
            dependencies: ["MDRichEditor"]),
    ]
)
