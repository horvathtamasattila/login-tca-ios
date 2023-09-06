import MobilityAPIClientInterface
import Get
import SharedDomain

struct CustomerDTO: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let referralUrl: String
    let isReferred: Bool
    let tierUserId: String
    let isEmailVerified: Bool
    let stepsCompleted: [String]
    let intercomHash: String?
}

extension MobilityAPIClient.Registration {
    static let liveValue: Self = .init(
        fetchCustomer: {
            let request = Request<Response<CustomerDTO>>(
                path: "/dummyPath"
            )
            let response = try await httpClient.send(request).value
            return .init(from: response)
        }
    )
}

extension Customer {
    init(from response: Response<CustomerDTO>) {
        self.init(
            tierUserId: response.attributes.tierUserId,
            email: response.attributes.email
        )
    }
}
