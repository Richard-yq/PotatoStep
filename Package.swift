// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PotatoStep",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PotatoStep",
            targets: ["PotatoStep"]),
    ],
    targets: [
        .target(
            name: "PotatoStep",
            path: ".",
            exclude: ["Info.plist", "README.md", "assert"],
            sources: [
                "StepTrackerApp.swift",
                "Models",
                "Services",
                "ViewModels",
                "Views"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
