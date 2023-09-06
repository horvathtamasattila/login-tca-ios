import SharedDomain

extension MobilityAPIClient {
    public struct Registration {
        public init(fetchCustomer: @escaping () async throws -> Customer) {
            self.fetchCustomer = fetchCustomer
        }

        public var fetchCustomer: () async throws -> Customer
    }
}

extension MobilityAPIClient.Registration {
    static let testValue: Self = .init(
        fetchCustomer: {
            Customer(
                tierUserId: "00000000-0000-0000-0000-000000000000",
                email: "preview@tier.app"
            )
        }
    )
}
