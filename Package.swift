// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IOS-step-app",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "IOS-step-app",
            targets: ["IOS-step-app"]),
    ],
    targets: [
        .target(
            name: "IOS-step-app",
            path: ".",
            exclude: ["Info.plist", "README.md"],
            sources: [
                "StepTrackerApp.swift",
                "Models",
                "Services",
                "ViewModels",
                "Views"
            ]
        )
    ]
)
