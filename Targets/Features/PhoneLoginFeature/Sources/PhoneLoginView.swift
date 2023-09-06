import ComposableArchitecture
import FirebaseAuthClientInterface
import SharedDomain
import SwiftUI

public struct PhoneLoginView: View {
    private let store: StoreOf<PhoneLogin>

    public init(store: StoreOf<PhoneLogin>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                TextField(
                    "Phone Number",
                    text: viewStore.binding(
                        get: \.phoneNumber,
                        send: PhoneLogin.Action.phoneNumberDidChange
                    )
                    .removeDuplicates()
                )
                .padding(8)

                if viewStore.verificationID.isNonEmpty {
                    TextField(
                        "Verification Code",
                        text: viewStore.binding(
                            get: \.verificationCode,
                            send: PhoneLogin.Action.verificationCodeDidChange
                        )
                        .removeDuplicates()
                    )
                    .padding(8)
                }

                if viewStore.isLoading {
                    ProgressView()
                } else {
                    if viewStore.verificationID.isNonEmpty {
                        Button("Verify") {
                            viewStore.send(.enterVerificationCodeDidTap)
                        }
                    } else {
                        Button("Sign In") {
                            viewStore.send(.enterPhoneNumberDidTap)
                        }
                    }
                }
            }
            .padding(16)
            .textFieldStyle(.roundedBorder)
            .sheet(item: viewStore.binding(
                get: \.error,
                send: PhoneLogin.Action.errorSheetDismissed
            )) { error in
                ErrorSheet(error: error)
            }
        }
    }
}

struct ErrorSheet: View {
    let error: PhoneLogin.Error

    var body: some View {
        VStack(alignment: .leading) {
            Text(error.title)
                .font(.largeTitle)
                .padding(.bottom, 16)
            Text(error.description)
        }
        .padding(32)
    }
}

extension PhoneLogin.Error {
    var title: String {
        switch self {
        case let PhoneLogin.Error.firebaseAuthClient(authError):
            switch authError {
            case .quotaExceeded: return "Too many login attempts"
            case .invalidCredential: return "Login data seems invalid"
            case .invalidPhoneNumber: return "Phone number seems invalid"
            case .captchaCheckFailed: return "Failed security check"
            case .sessionExpired: return "Session expired"
            }
        case .fraud: return "Suspicious activity"
        case .unsupportedCountry: return "Unsupported country"
        }
    }

    var description: String {
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum nunc diam, aliquam et purus et, porttitor finibus sem. Morbi in tempor ligula. Praesent enim nisl, iaculis non venenatis venenatis, pulvinar sed nunc."
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView(store:
            .init(
                initialState: .init(),
                reducer: PhoneLogin()
            )
        )
        .previewDisplayName("Happy path")

        PhoneLoginView(store:
            .init(
                initialState: .init(),
                reducer: PhoneLogin()
                    .dependency(\.firebaseAuthClient, throwingFirebaseAuthClient)
            )
        )
        .previewDisplayName("Error sheet")
    }
}

let throwingFirebaseAuthClient: FirebaseAuthClient = .init(
    configure: {},
    fetchUser: { throw FirebaseAuthClient.Error.invalidCredential },
    signIn: { _ in throw FirebaseAuthClient.Error.sessionExpired },
    verifyPhoneNumber: { _ in throw FirebaseAuthClient.Error.captchaCheckFailed },
    idToken: { nil }
)
