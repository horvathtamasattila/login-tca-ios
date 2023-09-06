import ComposableArchitecture
import FirebaseAuthClientInterface
import MobilityAPIClientInterface
import SharedAuth
import SharedDomain

// VM
public struct PhoneLogin: ReducerProtocol {
    enum Error: Swift.Error, Equatable, Identifiable {
        var id: String { "PhoneLoginError" }

        case firebaseAuthClient(FirebaseAuthClient.Error)
        case fraud
        case unsupportedCountry
    }

    enum Result: Equatable {
        case signedIn(Customer)
        case canceled
    }

    // enum ViewState {
    //     case loading
    //     case error(Error)
    //     case normal(Result)
    // }

    // VM output
    public struct State: Equatable {
        var phoneNumber: String = ""
        var isLoading: Bool = false
        var verificationID: Credential.VerificationID? = nil
        var verificationCode: Credential.VerificationCode = ""
        var error: Error? = nil
        var result: Result? = nil
        // var viewState: ViewState

        public init() {}
    }

    // VM input
    public enum Action: Equatable {
        case phoneNumberDidChange(String)
        case enterPhoneNumberDidTap
        case verificationIDResult(TaskResult<Credential.VerificationID>)
        case verificationCodeDidChange(Credential.VerificationCode)
        case enterVerificationCodeDidTap
        case signInResult(TaskResult<Customer>)
        case errorSheetDismissed
        case cancel
    }

    public init() {}

    // No UseCase
    @Dependency(\.firebaseAuthClient) var firebaseAuthClient
    @Dependency(\.mobilityAPIClient) var mobilityAPIClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .phoneNumberDidChange(number):
                state.phoneNumber = number
                return .none
            case .enterPhoneNumberDidTap:
                state.isLoading = true
                let phoneNumber = state.phoneNumber
                return .task {
                    do {
                        let verificationID = try await firebaseAuthClient.verifyPhoneNumber(phoneNumber)
                        return .verificationIDResult(.success(verificationID))
                    } catch {
                        return .verificationIDResult(.failure(error))
                    }
                }
            case let .verificationIDResult(result):
                state.isLoading = false
                switch result {
                case let .failure(error):
                    state.error = .mapFirebaseAuthClientError(error)
                    return .none
                case let .success(verificationID):
                    state.verificationID = verificationID
                    return .none
                }
            case let .verificationCodeDidChange(verificationCode):
                state.verificationCode = verificationCode
                return .none
            case .enterVerificationCodeDidTap:
                guard
                    let verificationID = state.verificationID,
                    !state.verificationCode.isEmpty
                else { return .none }
                state.isLoading = true
                let verificationCode = state.verificationCode
                return .task {
                    do {
                        _ = try await firebaseAuthClient.signIn(.phone(verificationID, verificationCode))
                        let customer = try await mobilityAPIClient.registration.fetchCustomer()
                        return .signInResult(.success(customer))
                    } catch {
                        return .signInResult(.failure(error))
                    }
                }
            case let .signInResult(result):
                state.isLoading = false
                switch result {
                case let .success(customer):
                    state.result = .signedIn(customer)
                case let .failure(error):
                    state.error = .mapFirebaseAuthClientError(error)
                }
                return .none
            case .errorSheetDismissed:
                state.error = nil
                return .none
            case .cancel:
                state.result = .canceled
                return .none
            }
        }
    }
}

extension PhoneLogin.Error {
    static func mapFirebaseAuthClientError(_ error: Error?) -> PhoneLogin.Error? {
        if let error = error as? FirebaseAuthClient.Error {
            return .firebaseAuthClient(error)
        }
        return nil
    }
}
