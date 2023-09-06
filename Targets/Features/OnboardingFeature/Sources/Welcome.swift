import AppleSSOClientInterface
import ComposableArchitecture
import FirebaseAuthClientInterface
import PhoneLoginFeature
import SharedDomain
import SSOFeature
import UIKit

public struct Welcome: ReducerProtocol {
    public enum Error: Swift.Error, Equatable, Identifiable {
        public var id: String { "WelcomeError" }

        case appleSSO(AppleSSOClient.Error)
        case firebase(FirebaseAuthClient.Error)
    }

    public struct State: Equatable {
        public var phoneLogin: PhoneLogin.State?
        public var error: Error?

        public init(phoneLogin: PhoneLogin.State? = nil, error: Error? = nil) {
            self.phoneLogin = phoneLogin
            self.error = error
        }
    }

    public enum Action: Equatable {
        case phoneLogin(PhoneLogin.Action)
        case phoneLoginDidTap
        case phoneLoginDismissed

        case appleLoginDidTap
        case googleLoginDidTap
        case ssoLoginResult(TaskResult<Customer>)

        case errorSheetDismissed
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .appleLoginDidTap:
                return .task {
                    let ssoFeature = SSOFeature()
                    do {
                        let customer = try await ssoFeature.launchAppleSignIn()
                        return .ssoLoginResult(.success(customer))
                    } catch {
                        return .ssoLoginResult(.failure(error))
                    }
                }
            case .phoneLoginDidTap:
                state.phoneLogin = .init()
                return .none
            case .phoneLoginDismissed:
                state.phoneLogin = nil
                return .none
            case .phoneLogin(.signInResult(.success)):
                state.phoneLogin = nil
                return .none
            case let .ssoLoginResult(result):
                if case let .failure(error) = result {
                    if let error = error as? AppleSSOClient.Error {
                        state.error = .appleSSO(error)
                    }
                    if let error = error as? FirebaseAuthClient.Error {
                        state.error = .firebase(error)
                    }
                }
                return .none
            case .errorSheetDismissed:
                state.error = nil
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.phoneLogin, action: /Action.phoneLogin) {
            PhoneLogin()
        }
    }
}
