import SharedAuth
import Dependencies
import UIKit

// MARK: - Interface

public struct GoogleSSOClient {
    public var signIn: (UIViewController) async throws -> Credential
    public var handleAppURL: (URL) -> Bool

    public init(
        signIn: @escaping (UIViewController) async throws -> Credential,
        handleAppURL: @escaping (URL) -> Bool
    ) {
        self.signIn = signIn
        self.handleAppURL = handleAppURL
    }
}

extension DependencyValues {
    public var googleSSOClient: GoogleSSOClient {
        get { self[GoogleSSOClient.self] }
        set { self[GoogleSSOClient.self] = newValue }
    }
}

extension GoogleSSOClient: TestDependencyKey {
    public static var testValue = {
        Self(
            signIn: { _ in .google("IDToken", "AccessToken") },
            handleAppURL: { _ in true }
        )
    }()

    public static var previewValue = testValue
}
