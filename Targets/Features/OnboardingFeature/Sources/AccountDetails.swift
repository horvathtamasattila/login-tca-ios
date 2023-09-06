import ComposableArchitecture
import SharedDomain

public struct AccountDetails: ReducerProtocol {
    public struct State: Equatable {}

    public enum Action: Equatable {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            .none
        }
    }
}
