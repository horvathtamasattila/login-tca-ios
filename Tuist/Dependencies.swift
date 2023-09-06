import ProjectDescription
import ProjectDescriptionHelpers

let carthageDependencies: [CarthageDependencies.Dependency] = [
    .binary(
        path: "https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json",
        requirement: .exact("9.6.0")
    ),
    .binary(
        path: "https://dl.google.com/dl/firebase/ios/carthage/FirebaseAuthBinary.json",
        requirement: .exact("9.6.0")
    ),
    .binary(
        path: "https://dl.google.com/dl/firebase/ios/carthage/FirebaseGoogleSignInBinary.json",
        requirement: .exact("9.6.0")
    )
]

let packages: [Package] = [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.42.0")),
    .package(url: "https://github.com/pointfreeco/swiftui-navigation", .exact("0.3.0")),
    .package(url: "https://github.com/kean/Get", .exact("2.1.4"))
]

let dependencies = Dependencies(
    carthage: .init(carthageDependencies),
    swiftPackageManager: .init(
        packages,
        productTypes: [
            "CasePaths": .framework,
            "CombineSchedulers": .framework,
            "ComposableArchitecture": .framework,
            "CustomDump": .framework,
            "Dependencies": .framework,
            "Get": .framework,
            "IdentifiedCollections": .framework,
            "OrderedCollections": .framework,
            "SwiftUINavigation": .framework,
            "XCTestDynamicOverlay": .framework,
        ]
    ),
    platforms: [.iOS]
)
