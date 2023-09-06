import AppleSSOClientInterface
import Dependencies
import ComposableArchitecture
import FirebaseAuthClientInterface
import GoogleSSOClientInterface
import RiderApp

extension FirebaseAuthClient {
    static var mockValue: FirebaseAuthClient = {
        Self(
            configure: testValue.configure,
            fetchUser: { nil },
            signIn:  { _ in throw FirebaseAuthClient.Error.invalidCredential },
            verifyPhoneNumber: testValue.verifyPhoneNumber,
            idToken: testValue.idToken
        )
    }()
}

extension StoreOf<RiderApp>: DependencyKey {
    public static var liveValue = {
        Store(
            initialState: .init(),
            reducer: RiderApp()
                .dependency(\.appleSSOClient, .testValue)
                .dependency(\.firebaseAuthClient, .mockValue)
                .dependency(\.googleSSOClient, .testValue)
                .dependency(\.mobilityAPIClient, .testValue)
                ._printChanges()
        )
    }()
}
