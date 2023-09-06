import Foundation

public struct Customer: Equatable {
    public let tierUserId: String?
    public let email: String

    public init(
        tierUserId: String?,
        email: String
    ) {
        self.tierUserId = tierUserId
        self.email = email
    }
}
