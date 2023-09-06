import AppleSSOClientInterface
import Dependencies
import FirebaseAuth
import FirebaseAuthClientInterface
import FirebaseCore
import SharedAuth

// MARK: - Implementation

extension FirebaseAuthClient: DependencyKey {
    public static let liveValue: FirebaseAuthClient = .init(
        configure: { FirebaseApp.configure() },
        fetchUser: fetchUser,
        signIn: signIn(with:),
        verifyPhoneNumber: verifyPhoneNumber,
        idToken: idToken
    )

    static func fetchUser() async throws -> FirebaseUser? {
        try await withCheckedThrowingContinuation { continuation in
            if let user = Auth.auth().currentUser {
                user.reload { error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    do {
                        let user: FirebaseUser = try .init(user: user)
                        continuation.resume(returning: user)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }

    static func signIn(with credential: Credential) async throws -> FirebaseUser {
        switch credential {
        case let .google(idToken, accessToken):
            return try await signInWithGoogle(idToken: idToken, accessToken: accessToken)
        case let .apple(idToken, nonce):
            return try await signInWithApple(idToken: idToken, nonce: nonce)
        case let .phone(verificationID, verificationCode):
            return try await signInWithPhoneNumber(verificationID: verificationID, verificationCode: verificationCode)
        }
    }

    static func signInWithGoogle(idToken: String, accessToken: String) async throws -> FirebaseUser {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        return try await signIn(with: credential)
    }

    static func signInWithApple(idToken: String, nonce: String) async throws -> FirebaseUser {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idToken,
            rawNonce: nonce
        )
        return try await signIn(with: credential)
    }

    static func signInWithPhoneNumber(verificationID: String, verificationCode: String) async throws -> FirebaseUser {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        return try await signIn(with: credential)
    }

    @MainActor static func signIn(
        with credential: AuthCredential
    ) async throws -> FirebaseUser {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if let result {
                    do {
                        let user = try FirebaseUser(user: result.user)
                        continuation.resume(returning: user)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    @MainActor private static func verifyPhoneNumber(
        _ phoneNumber: String
    ) async throws -> Credential.VerificationCode {
        try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = Error.mapVerifyPhoneNumberError(error) {
                    continuation.resume(throwing: error)
                    return
                }

                if let verificationID = verificationID {
                    continuation.resume(returning: verificationID)
                }
            }
        }
    }

    static func idToken() async throws -> String? {
        try await Auth.auth().currentUser?.getIDToken()
    }
}

private extension FirebaseUser {
    init(user: User) throws {
        self.init(firebaseId: user.uid, email: user.email)
    }
}

private extension FirebaseAuthClient.Error {
    static func mapSignInError(_ error: Error?) -> FirebaseAuthClient.Error? {
        guard let error else { return nil }
        switch error {
        case AuthErrorCode.invalidCredential: return .invalidCredential
        case AuthErrorCode.sessionExpired: return .sessionExpired
        default:
            print("Unmapped FirebaseAuth error \(error)")
            return nil
        }
    }

    static func mapVerifyPhoneNumberError(_ error: Error?) -> FirebaseAuthClient.Error? {
        guard let error else { return nil }
        switch error {
        case AuthErrorCode.captchaCheckFailed: return .captchaCheckFailed
        case AuthErrorCode.quotaExceeded: return .quotaExceeded
        case
            AuthErrorCode.invalidPhoneNumber,
            AuthErrorCode.missingPhoneNumber: return .invalidPhoneNumber
        default:
            print("Unmapped FirebaseAuth error \(error)")
            return nil
        }
    }
}
