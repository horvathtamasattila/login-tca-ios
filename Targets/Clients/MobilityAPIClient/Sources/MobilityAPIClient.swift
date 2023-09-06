import Dependencies
import Foundation
import Get
import MobilityAPIClientInterface

let httpClient: APIClient = {
    var configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Dictionary(uniqueKeysWithValues: [
        AdditionalHeaders.defaultAcceptEncoding,
        AdditionalHeaders.defaultAcceptLanguage,
        AdditionalHeaders.defaultUserAgent
    ])

    return APIClient(
        configuration: .init(
            baseURL: .init(string: "https://dummy-api.io"),
            sessionConfiguration: configuration,
            delegate: FirebaseAuthDelegate()
        )
    )
}()

extension MobilityAPIClient: DependencyKey {
    public static var liveValue: Self = {
        .init(registration: .liveValue)
    }()
}
