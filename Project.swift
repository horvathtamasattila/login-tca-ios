import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Shared

enum Shared {
    static let SharedAuth: Target = .shared(name: "SharedAuth")

    static let SharedDomain: Target = .shared(name: "SharedDomain")

    static let SharedFirebaseSDK: Target = .shared(
        name: "SharedFirebaseSDK",
        dependencies: [
            .external(name: "AppAuth"),
            .external(name: "FBLPromises"),
            .external(name: "FirebaseAnalytics"),
            .external(name: "FirebaseAnalyticsSwift"),
            .external(name: "FirebaseAuth"),
            .external(name: "FirebaseCore"),
            .external(name: "FirebaseCoreDiagnostics"),
            .external(name: "FirebaseCoreInternal"),
            .external(name: "FirebaseInstallations"),
            .external(name: "GoogleAppMeasurement"),
            .external(name: "GoogleAppMeasurementIdentitySupport"),
            .external(name: "GoogleDataTransport"),
            .external(name: "GoogleSignIn"),
            .external(name: "GoogleUtilities"),
            .external(name: "GTMAppAuth"),
            .external(name: "GTMSessionFetcher"),
            .external(name: "nanopb")
        ],
        settings: .settings(base: [
            "OTHER_LDFLAGS": "-all_load"
        ])
    )
}

// MARK: - Clients

enum Client {
    static let (AppleSSOClientInterface, AppleSSOClient) =
        Target.client(
            name: "AppleSSOClient",
            interfaceDependencies: [Shared.SharedAuth.dependency]
        )

    static let (FirebaseAuthClientInterface, FirebaseAuthClient) =
        Target.client(
            name: "FirebaseAuthClient",
            interfaceDependencies: [
                Shared.SharedAuth.dependency
            ],
            dependencies: [Shared.SharedFirebaseSDK.dependency]
        )

    static let (GoogleSSOClientInterface, GoogleSSOClient) =
        Target.client(
            name: "GoogleSSOClient",
            interfaceDependencies: [Shared.SharedAuth.dependency],
            dependencies: [Shared.SharedFirebaseSDK.dependency]
        )

    static let (MobilityAPIClientInterface, MobilityAPIClient) =
        Target.client(
            name: "MobilityAPIClient",
            interfaceDependencies: [Shared.SharedAuth.dependency],
            dependencies: [
                Client.FirebaseAuthClientInterface.dependency,
                .external(name: "Get")
            ]
        )
}

// MARK: - Features

enum Feature {
    static let (SplashFeature, SplashFeatureTests) =
        Target.feature(
            name: "SplashFeature",
            dependencies: [
                Client.FirebaseAuthClientInterface.dependency,
                Client.MobilityAPIClientInterface.dependency,
                Shared.SharedDomain.dependency
            ]
        )

    static let (PhoneLoginFeature, PhoneLoginFeatureTests) =
        Target.feature(
            name: "PhoneLoginFeature",
            dependencies: [
                Client.FirebaseAuthClientInterface.dependency,
                Client.MobilityAPIClientInterface.dependency,
                Shared.SharedDomain.dependency
            ]
        )

    static let (SSOFeature, SSOFeatureTests) =
        Target.feature(
            name: "SSOFeature",
            dependencies: [
                Client.AppleSSOClientInterface.dependency,
                Client.FirebaseAuthClientInterface.dependency,
                Client.GoogleSSOClientInterface.dependency,
                Client.MobilityAPIClientInterface.dependency
            ]
        )

    static let (OnboardingFeature, OnboardingFeatureTests) =
        Target.feature(
            name: "OnboardingFeature",
            dependencies: [
                Feature.PhoneLoginFeature.dependency,
                Feature.SSOFeature.dependency
            ]
        )
}

// MARK: - RiderApp

let RiderApp = Target(
    name: "RiderApp",
    platform: .iOS,
    product: .framework,
    bundleId: "app.tier.RiderApp",
    deploymentTarget: Project.deploymentTarget,
    sources: ["Targets/RiderApp/Sources/**"],
    dependencies: [
        .external(name: "ComposableArchitecture"),
        Feature.OnboardingFeature.dependency,
        Feature.PhoneLoginFeature.dependency,
        Feature.SplashFeature.dependency,
        Feature.SSOFeature.dependency
    ]
)

// MARK: - Project

let project = Project(
    name: "RiderApp",
    organizationName: "tier.app",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .notGrouped,
            codeCoverageEnabled: true
        )
    ),
    targets: [
        .app(
            name: "RiderApp-iOS",
            bundleId: "app.tier.sharing.debug",
            sources: "Targets/RiderApp-iOS/Production/**",
            dependencies: [
                Client.AppleSSOClient.dependency,
                Client.FirebaseAuthClient.dependency,
                Client.GoogleSSOClient.dependency,
                Client.MobilityAPIClient.dependency,
                Shared.SharedFirebaseSDK.dependency,
            ],
            settings: .settings(base: [
                "OTHER_LDFLAGS": "-ObjC",
                "REVERSED_CLIENT_ID": "com.googleusercontent.apps.511116665713-tesh9i10v8u50kllk31hk6430dgv265o"
            ])
        ),
        .app(
            name: "RiderApp-iOS-Mock",
            bundleId: "app.tier.sharing.mock",
            sources: "Targets/RiderApp-iOS/Mock/**"
        ),
        RiderApp,
        Client.AppleSSOClient,
        Client.AppleSSOClientInterface,
        Client.FirebaseAuthClient,
        Client.FirebaseAuthClientInterface,
        Client.GoogleSSOClient,
        Client.GoogleSSOClientInterface,
        Client.MobilityAPIClient,
        Client.MobilityAPIClientInterface,
        Feature.OnboardingFeature,
        Feature.OnboardingFeatureTests,
        Feature.PhoneLoginFeature,
        Feature.PhoneLoginFeatureTests,
        Feature.SplashFeature,
        Feature.SplashFeatureTests,
        Feature.SSOFeature,
        Feature.SSOFeatureTests,
        Shared.SharedAuth,
        Shared.SharedDomain,
        Shared.SharedFirebaseSDK
    ]
)
