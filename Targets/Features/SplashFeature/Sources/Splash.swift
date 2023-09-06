import ComposableArchitecture
import FirebaseAuthClientInterface
import MobilityAPIClientInterface
import SharedDomain

public struct Splash: ReducerProtocol {
    public enum Result: Equatable {
        case loggedIn(Customer)
        case loggedOut
    }

    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {
        case fetchCustomer
        case completed(TaskResult<Result>)
    }

    @Dependency(\.firebaseAuthClient) var firebaseAuthClient
    @Dependency(\.mobilityAPIClient) var mobilityAPIClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchCustomer:
                return .task {
                    do {
                        let user = try await firebaseAuthClient.fetchUser()
                        if user == nil {
                            return .completed(.success(.loggedOut))
                        } else {
                            let customer = try await mobilityAPIClient.registration.fetchCustomer()
                            return .completed(.success(.loggedIn(customer)))
                        }
                    } catch {
                        return .completed(.failure(error))
                    }
                }
            case .completed(let result):
                if case let .failure(error) = result {
                    print(error)
                }
                return .none
            }
        }
    }
}
