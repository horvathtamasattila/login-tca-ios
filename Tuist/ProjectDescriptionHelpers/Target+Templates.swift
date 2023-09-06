import ProjectDescription

let iOSInfoPlist: [String: InfoPlist.Value] = [
    "CFBundleShortVersionString": "0.1.0",
    "CFBundleVersion": "1",
    "UIMainStoryboardFile": "",
    "UILaunchStoryboardName": "LaunchScreen",
    "CFBundleURLTypes": .array([
        .dictionary([
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["$(REVERSED_CLIENT_ID)"]
        ])
    ]),
    "FirebaseAutomaticScreenReportingEnabled": false
]

extension Target {
    public static func shared(
        name: String,
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "app.tier.\(name)",
            deploymentTarget: Project.deploymentTarget,
            sources: ["Targets/\(name)/**"],
            dependencies: dependencies + [
                .external(name: "ComposableArchitecture")
            ],
            settings: settings
        )
    }

    public static func client(
        name: String,
        interfaceDependencies: [TargetDependency] = [],
        dependencies: [TargetDependency] = []
    ) -> (Target, Target) {
        let interface = Target(
            name: "\(name)Interface",
            platform: .iOS,
            product: .framework,
            bundleId: "app.tier.\(name)Interface",
            deploymentTarget: Project.deploymentTarget,
            sources: ["Targets/Clients/\(name)/Interface/**"],
            dependencies: interfaceDependencies + [
                .external(name: "ComposableArchitecture")
            ]
        )

        let client = Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "app.tier.\(name)",
            deploymentTarget: Project.deploymentTarget,
            sources: ["Targets/Clients/\(name)/Sources/**"],
            dependencies: dependencies + [
                .target(name: "\(name)Interface")
            ]
        )

        return (interface, client)
    }

    public static func feature(
        name: String,
        dependencies: [TargetDependency] = []
    ) -> (Target, Target) {
        let feature = Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "app.tier.\(name)",
            deploymentTarget: Project.deploymentTarget,
            sources: ["Targets/Features/\(name)/Sources/**"],
            dependencies: dependencies + [
                .external(name: "ComposableArchitecture"),
                .external(name: "SwiftUINavigation")
            ]
        )

        let tests = Target(
            name: "\(name)Tests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "app.tier.\(name)",
            deploymentTarget: Project.deploymentTarget,
            sources: ["Targets/Features/\(name)/Tests/**"],
            dependencies: [
                .target(name: name)
            ]
        )

        return (feature, tests)
    }

    public static func app(
        name: String,
        bundleId: String,
        sources: SourceFileGlob,
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTarget: Project.deploymentTarget,
            infoPlist: .extendingDefault(with: iOSInfoPlist),
            sources: [
                "Targets/RiderApp-iOS/Sources/**",
                sources
            ],
            resources: ["Targets/RiderApp-iOS/Resources/**"],
            entitlements: "Targets/RiderApp-iOS/Tier.entitlements",
            dependencies: dependencies + [
                .target(name: "RiderApp")
            ],
            settings: settings
        )
    }
}

extension Target {
    public var dependency: TargetDependency {
        get { .target(name: name) }
    }
}
