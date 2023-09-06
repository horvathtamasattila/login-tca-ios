import ComposableArchitecture
import FirebaseAuthClientInterface
import OnboardingFeature
import SharedDomain
import SplashFeature
import UIKit

public struct RiderApp: ReducerProtocol {
    public struct State: Equatable {
        /// app states
        var customer: Customer?

        /// child states
        var splash: Splash.State?
        var onboarding: Onboarding.State?

        public init() {}
    }

    public enum Action: Equatable {
        /// app actions
        case initialize
        case launchSplash
        case launchOnboarding

        /// child actions
        case splash(Splash.Action)
        case onboarding(Onboarding.Action)
    }

    @Dependency(\.appStore) var appStore
    @Dependency(\.coordinator) var coordinator
    @Dependency(\.firebaseAuthClient) var firebaseAuthClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                firebaseAuthClient.configure()
                state.splash = .init()
                return .task { .launchSplash }
            case .launchSplash:
                let splashFeature = SplashFeature(
                    store: appStore.scope(state: \.splash, action: RiderApp.Action.splash)
                )
                splashFeature.launch()
                return .none
            case .launchOnboarding:
                let onboardingFeature = OnboardingFeature(
                    store: appStore.scope(state: \.onboarding, action: RiderApp.Action.onboarding)
                )
                onboardingFeature.launch()
                return .none
            case .splash(.completed(.success(let result))):
                state.splash = nil
                switch result {
                case .loggedIn(let customer):
                    state.customer = customer
                    let vc = UIViewController()
                    vc.view.backgroundColor = .brown
                    coordinator.rootViewController.setViewControllers([vc], animated: false)
                    return .none
                case .loggedOut:
                    state.onboarding = .welcome(.init())
                    return .task { .launchOnboarding }
                }
            case .splash:
                return .none
            case .onboarding(.completed(.success(let customer))):
                state.customer = customer
                state.onboarding = nil
                return .none
            case .onboarding:
                return .none
            }
        }
        .ifLet(\.splash, action: /Action.splash) {
            Splash()
        }
        .ifLet(\.onboarding, action: /Action.onboarding) {
            Onboarding()
        }
    }
}

extension DependencyValues {
    public var appStore: StoreOf<RiderApp> {
        get { self[StoreOf<RiderApp>.self] }
        set { self[StoreOf<RiderApp>.self] = newValue }
    }
}

extension StoreOf<RiderApp>: TestDependencyKey {
    public static var testValue = {
        Store(
            initialState: .init(),
            reducer: RiderApp()
        )
    }()
}
