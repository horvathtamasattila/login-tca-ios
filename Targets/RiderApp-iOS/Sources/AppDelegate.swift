import ComposableArchitecture
import GoogleSSOClientInterface
import Dependencies
import SharedDomain
import RiderApp
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    @Dependency(\.appStore) var appStore
    @Dependency(\.coordinator) var coordinator
    @Dependency(\.googleSSOClient) var googleSSOClient

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.rootViewController
        window?.makeKeyAndVisible()

        let viewStore: ViewStoreOf<RiderApp> = .init(appStore)
        viewStore.send(.initialize)

        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        return googleSSOClient.handleAppURL(url)
    }
}
