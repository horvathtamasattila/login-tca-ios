import Dependencies
import SharedDomain

public struct MobilityAPIClient {
    public let registration: Registration

    public init(registration: Registration) {
        self.registration = registration
    }
}

extension DependencyValues {
    public var mobilityAPIClient: MobilityAPIClient {
        get { self[MobilityAPIClient.self] }
        set { self[MobilityAPIClient.self] = newValue }
    }
}

extension MobilityAPIClient: TestDependencyKey {
    public static var testValue = {
        Self(
            registration: .testValue
        )
    }()

    public static var previewValue = testValue
}
