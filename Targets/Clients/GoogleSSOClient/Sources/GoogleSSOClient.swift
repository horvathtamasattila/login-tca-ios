import SharedAuth
import Dependencies
import FirebaseCore
import GoogleSignIn
import GoogleSSOClientInterface

// MARK: - Implementation

extension GoogleSSOClient: DependencyKey {
    public static var liveValue = {
        Self(
            signIn: signIn(presenting:),
            handleAppURL: handleAppURL
        )
    }()

    @MainActor static func signIn(
        presenting viewController: UIViewController
    ) async throws -> Credential {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Firebase ClientID is nil")
        }

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                with: GIDConfiguration(clientID: clientID),
                presenting: viewController
            ) { user, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user, let idToken = user.authentication.idToken else {
                    fatalError("idToken is nil")
                }

                continuation.resume(returning: .google(idToken, user.authentication.accessToken))
            }
        }
    }

    static func handleAppURL(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
