import Combine
import ComposableArchitecture
import SharedDomain
import UIKit

public class OnboardingFeature {
    @Dependency(\.coordinator) var coordinator

    private let store: Store<Onboarding.State?, Onboarding.Action>

    private var cancellables: Set<AnyCancellable> = []

    public init(store: Store<Onboarding.State?, Onboarding.Action>) {
        self.store = store
    }

    public func launch() {
        store.ifLet { store in
            let onboardingView = OnboardingView(store: store)
            let viewController = ViewController(rootView: onboardingView)
            self.coordinator.rootViewController.pushViewController(viewController, animated: true)
        } else: {
            self.coordinator.rootViewController.popViewController(animated: true)
            self.cancellables = []
        }
        .store(in: &cancellables)
    }
}
