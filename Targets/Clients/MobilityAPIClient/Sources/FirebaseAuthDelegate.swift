import Dependencies
import FirebaseAuthClientInterface
import Foundation
import Get

class FirebaseAuthDelegate: APIClientDelegate {
    @Dependency(\.firebaseAuthClient) var firebaseAuthClient

    func client(_ client: APIClient, willSendRequest request: inout URLRequest) async throws {
        if let idToken = try? await firebaseAuthClient.idToken() {
            request.setValue("\(idToken)", forHTTPHeaderField: "")
        }
    }
}
