import Dependencies
import ComposableArchitecture
import RiderApp

extension StoreOf<RiderApp>: DependencyKey {
    public static var liveValue = {
        Store(
            initialState: .init(),
            reducer: RiderApp()
        )
    }()
}
