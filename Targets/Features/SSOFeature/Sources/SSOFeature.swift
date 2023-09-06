import AppleSSOClientInterface
import Dependencies
import FirebaseAuthClientInterface
import GoogleSSOClientInterface
import MobilityAPIClientInterface
import SharedDomain
import UIKit

extension UINavigationController: ViewControllerContextProvider {}

public class SSOFeature {
    @Dependency(\.coordinator) var coordinator
    @Dependency(\.appleSSOClient) var appleSSOClient
    @Dependency(\.googleSSOClient) var googleSSOClient
    @Dependency(\.firebaseAuthClient) var firebaseAuthClient
    @Dependency(\.mobilityAPIClient) var mobilityAPIClient

    public init() {}

    public func launchAppleSignIn() async throws -> Customer {
        let credential = try await appleSSOClient.signIn(coordinator.rootViewController)
        _ = try await firebaseAuthClient.signIn(credential)
        return try await mobilityAPIClient.registration.fetchCustomer()
    }

    public func launchGoogleSignIn() async throws -> Customer {
        let credential = try await googleSSOClient.signIn(coordinator.rootViewController)
        _ = try await firebaseAuthClient.signIn(credential)
        return try await mobilityAPIClient.registration.fetchCustomer()
    }
}
