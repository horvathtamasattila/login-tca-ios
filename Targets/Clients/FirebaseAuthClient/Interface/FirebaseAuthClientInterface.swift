import Dependencies
import SharedAuth

// MARK: - Interface

public struct FirebaseUser {
    public let firebaseId: String
    public let email: String?

    public init(firebaseId: String, email: String?) {
        self.firebaseId = firebaseId
        self.email = email
    }
}

public struct FirebaseAuthClient {
    public enum Error: Swift.Error, Equatable {
        case invalidCredential
        case invalidPhoneNumber
        case captchaCheckFailed
        case sessionExpired
        case quotaExceeded
    }

    public var configure: () -> Void
    public var fetchUser: () async throws -> FirebaseUser?
    public var signIn: (Credential) async throws -> FirebaseUser
    public var verifyPhoneNumber: (String) async throws -> Credential.VerificationCode
    public var idToken: () async throws -> String?

    public init(
        configure: @escaping () -> Void,
        fetchUser: @escaping () async throws -> FirebaseUser?,
        signIn: @escaping (Credential) async throws -> FirebaseUser,
        verifyPhoneNumber: @escaping (String) async throws -> Credential.VerificationCode,
        idToken: @escaping () async throws -> String?
    ) {
        self.configure = configure
        self.fetchUser = fetchUser
        self.signIn = signIn
        self.verifyPhoneNumber = verifyPhoneNumber
        self.idToken = idToken
    }
}

extension FirebaseAuthClient: TestDependencyKey {
    public static let testValue: FirebaseAuthClient = .init(
        configure: {},
        fetchUser: {
            FirebaseUser(
                firebaseId: "00000000-0000-0000-0000-000000000000",
                email: "preview@tier.app"
            )
        },
        signIn: { _ in
            FirebaseUser(
                firebaseId: "00000000-0000-0000-0000-000000000000",
                email: "preview@tier.app"
            )
        },
        verifyPhoneNumber: { _ in "0000" },
        idToken: { "id_token" }
    )

    public static var previewValue: FirebaseAuthClient = testValue
}

extension DependencyValues {
    public var firebaseAuthClient: FirebaseAuthClient {
        get { self[FirebaseAuthClient.self] }
        set { self[FirebaseAuthClient.self] = newValue }
    }
}
