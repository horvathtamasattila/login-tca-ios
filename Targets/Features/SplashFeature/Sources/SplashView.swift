import ComposableArchitecture
import SwiftUI

struct SplashView: View {
    let store: StoreOf<Splash>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("TIER")
                .font(.largeTitle)
                .onAppear {
                    viewStore.send(.fetchCustomer)
                }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(store: .init(
            initialState: .init(),
            reducer: Splash()
        ))
    }
}
