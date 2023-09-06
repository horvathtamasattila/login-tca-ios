import ComposableArchitecture
import PhoneLoginFeature
import SharedDomain
import SSOFeature

public struct Onboarding: ReducerProtocol {
    public enum State: Equatable {
        case welcome(Welcome.State)
        case termsAndConditions(TermsAndConditions.State)
        case accountDetails(AccountDetails.State)
    }

    public enum Action: Equatable {
        case welcome(Welcome.Action)
        case termsAndConditions(TermsAndConditions.Action)
        case accountDetails(AccountDetails.Action)
        case completed(TaskResult<Customer>)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .welcome(.phoneLogin(.signInResult(.success(let customer)))):
                return .task {
                    .completed(.success(customer))
                }
            case .welcome(.ssoLoginResult(.success(let customer))):
                return .task {
                    .completed(.success(customer))
                }
            default: return .none
            }
        }
        .ifCaseLet(/State.welcome, action: /Action.welcome) {
            Welcome()
        }
        .ifCaseLet(/State.termsAndConditions, action: /Action.termsAndConditions) {
            TermsAndConditions()
        }
        .ifCaseLet(/State.accountDetails, action: /Action.accountDetails) {
            AccountDetails()
        }
    }
}
