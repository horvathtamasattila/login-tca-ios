import AppleSSOClientInterface
import ComposableArchitecture
import PhoneLoginFeature
import SwiftUINavigation
import SwiftUI

struct WelcomeView: View {
    let store: StoreOf<Welcome>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(alignment: .leading) {
                    Text("Welcome").font(.largeTitle).padding(.bottom, 32)

                    Button("Phone Login") {
                        viewStore.send(.phoneLoginDidTap)
                    }.padding(.bottom, 16)

                    Button("Apple Login") {
                        viewStore.send(.appleLoginDidTap)
                    }.padding(.bottom, 16)

                    Button("Google Login") {
                        viewStore.send(.googleLoginDidTap)
                    }.padding(.bottom, 16)

                    NavigationLink(
                        isActive: viewStore.binding(
                            get: { $0.phoneLogin != nil },
                            send: Welcome.Action.phoneLoginDismissed
                        ),
                        destination: {
                            IfLetStore(
                                store.scope(state: \.phoneLogin, action: Welcome.Action.phoneLogin),
                                then: { PhoneLoginView(store: $0) }
                            )
                        },
                        label: { EmptyView() }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(32)
            }
            .sheet(item: viewStore.binding(
                get: \.error,
                send: Welcome.Action.errorSheetDismissed
            )) { error in
                ErrorSheet(error: error)
            }
        }
    }
}

struct ErrorSheet: View {
    let error: Welcome.Error

    var body: some View {
        VStack(alignment: .leading) {
            Text(error.title)
                .font(.largeTitle)
                .padding(.bottom, 16)
            Text(error.localizedDescription)
        }
        .padding(32)
    }
}

extension Welcome.Error {
    var title: String { "\(type(of: self))" }
}

extension AppleSSOClient {
    static let throwing: Self = .init(
        signIn: { _ in throw AppleSSOClient.Error.canceled }
    )
}

struct WelcomeView_Previws: PreviewProvider {
    static var previews: some View {
        WelcomeView(store: .init(
            initialState: .init(),
            reducer: Welcome()
            .dependency(\.appleSSOClient, .throwing)
        ))
    }
}
