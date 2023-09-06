import ComposableArchitecture
import SharedDomain
import XCTest

@testable import PhoneLoginFeature

@MainActor
final class SSOFeatureTests: XCTestCase {
    func test_Feature_HappyPath() async {
        let store = TestStore(
            initialState: PhoneLogin.State(),
            reducer: PhoneLogin()
        )

        await store.send(.phoneNumberDidChange("asd")) {
            $0.phoneNumber = "asd"
        }

        await store.send(.enterPhoneNumberDidTap) {
            $0.isLoading = true
        }
        await store.receive(.verificationIDResult(.success("0000"))) {
            $0.isLoading = false
            $0.verificationID = "0000"
        }

        await store.send(.verificationCodeDidChange("1111")) {
            $0.verificationCode = "1111"
        }

        await store.send(.enterVerificationCodeDidTap) {
            $0.isLoading = true
        }

        let customer = Customer(
            tierUserId: "00000000-0000-0000-0000-000000000000",
            email: "preview@tier.app"
        )
        await store.receive(.signInResult(.success(customer))) {
            $0.isLoading = false
            $0.result = .signedIn(customer)
        }
    }

    func test_Input_InvalidPhoneNumber() async {}
}
