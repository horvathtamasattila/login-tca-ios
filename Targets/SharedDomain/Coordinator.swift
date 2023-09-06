import Dependencies
import UIKit

public class Coordinator {
    public let rootViewController: UINavigationController

    public init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController

        rootViewController.isNavigationBarHidden = true
    }
}

extension DependencyValues {
    public var coordinator: Coordinator {
        get { self[Coordinator.self] }
        set { self[Coordinator.self] = newValue }
    }
}

extension Coordinator: TestDependencyKey {
    public static var testValue = {
        Coordinator(rootViewController: UINavigationController())
    }()

    public static var previewValue = testValue
}

extension Coordinator: DependencyKey {
    public static var liveValue = {
        Coordinator(rootViewController: UINavigationController())
    }()
}
