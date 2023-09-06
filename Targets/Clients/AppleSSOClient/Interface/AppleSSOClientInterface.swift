import SharedAuth
import Dependencies
import UIKit

// MARK: - Interface

public protocol ViewControllerContextProvider: UIViewController {}

public struct AppleSSOClient {
    public enum Error: Swift.Error, Equatable {
        case authorization
        case canceled
    }

    public init(
        signIn: @escaping (ViewControllerContextProvider) async throws -> Credential
    ) {
        self.signIn = signIn
    }

    public var signIn: (ViewControllerContextProvider) async throws -> Credential
}

extension DependencyValues {
    public var appleSSOClient: AppleSSOClient {
        get { self[AppleSSOClient.self] }
        set { self[AppleSSOClient.self] = newValue }
    }
}

extension AppleSSOClient: TestDependencyKey {
    public static var testValue = {
        Self(
            signIn: { _ in .apple("IDToken", "Nonce") }
        )
    }()

    public static var previewValue = testValue
}
