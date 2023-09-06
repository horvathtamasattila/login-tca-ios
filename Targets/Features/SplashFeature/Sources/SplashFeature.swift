import Combine
import ComposableArchitecture
import SharedDomain
import SwiftUI
import UIKit

public class SplashFeature {
    @Dependency(\.coordinator) var coordinator

    private let store: Store<Splash.State?, Splash.Action>

    private var cancellables: Set<AnyCancellable> = []

    public init(store: Store<Splash.State?, Splash.Action>) {
        self.store = store
    }

    public func launch() {
        store.ifLet { store in
            let splashView = SplashView(store: store)
            let viewController = ViewController(rootView: splashView)
            self.coordinator.rootViewController.setViewControllers([viewController], animated: false)
        } else: {
            self.cancellables = []
        }
        .store(in: &cancellables)
    }
}
