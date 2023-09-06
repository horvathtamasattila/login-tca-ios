import AppleSSOClientInterface
import SharedAuth
import AuthenticationServices
import Dependencies

// MARK: - Implementation

extension AppleSSOClient: DependencyKey {
    public static var liveValue = {
        Self(
            signIn: signIn(contextProvider:)
        )
    }()

    @MainActor static func signIn(contextProvider: ViewControllerContextProvider) async throws -> Credential {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let nonce = randomNonceString()
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.presentationContextProvider = contextProvider

        let asyncController = AsyncASAuthorizationController(
            nonce: nonce,
            wrap: ASAuthorizationController(authorizationRequests: [request])
        )

        return try await asyncController.performRequests()
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

class AsyncASAuthorizationController: NSObject, ASAuthorizationControllerDelegate {
    private var continuation: CheckedContinuation<Credential, Error>?

    private let nonce: String
    private let authorizationController: ASAuthorizationController

    init(nonce: String, wrap: ASAuthorizationController) {
        self.nonce = nonce
        self.authorizationController = wrap
    }

    func performRequests() async throws -> Credential {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }

            self.continuation = continuation

            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credential.identityToken,
            let token = String(data: identityToken, encoding: .utf8)
        {
            continuation?.resume(returning: .apple(token, nonce))
        } else {
            fatalError("Apple ID Credential is nil")
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let error = error.map() {
            continuation?.resume(throwing: error)
        }
    }
}

/// ASAuthorizationError:
/// ---------------------
/// case unknown = 1000
/// case canceled = 1001
/// case invalidResponse = 1002
/// case notHandled = 1003
/// case failed = 1004
/// case notInteractive = 1005

private extension Swift.Error {
    func map() -> AppleSSOClient.Error? {
        switch self {
        case ASAuthorizationError.unknown: return .authorization
        case ASAuthorizationError.failed: return .authorization
        case ASAuthorizationError.canceled: return .canceled
        default:
            print("Unmapped Apple SSO error")
            return nil
        }
    }
}
