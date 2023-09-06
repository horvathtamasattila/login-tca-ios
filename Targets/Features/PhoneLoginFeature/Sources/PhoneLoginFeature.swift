import ComposableArchitecture
import Combine
import SharedDomain
import SwiftUI
import UIKit

public class PhoneLoginFeature {
    public init() {
        print("### init PhoneLoginFeature")
    }

    @MainActor public func launch(from root: UIViewController) async -> Customer? {
        defer {
            print("### defer PhoneLoginFeature")
        }

        let store: StoreOf<PhoneLogin> = .init(
            initialState: .init(),
            reducer: PhoneLogin()
        )

        let phoneLoginView = PhoneLoginView(store: store)
        let viewController = ViewController(rootView: phoneLoginView)

        let viewStore = ViewStore(store)

        viewController.onDismissed {
            print("### onDismissed PhoneLoginFeature")
            viewStore.send(.cancel)
        }

        root.present(viewController, animated: true)

        for await result in viewStore.publisher.result.values {
            if let result {
                viewController.dismiss(animated: true)
                switch result {
                case .signedIn(let customer): return customer
                case .canceled: return nil
                }
            }
        }

        return nil
    }

    deinit {
        print("### deinit PhoneLoginFeature")
    }
}
