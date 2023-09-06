import ComposableArchitecture
import PhoneLoginFeature
import SharedDomain
import SwiftUI

struct OnboardingView: View {
    let store: StoreOf<Onboarding>

    var body: some View {
        SwitchStore(self.store) {
            CaseLet(state: /Onboarding.State.welcome, action: Onboarding.Action.welcome) { store in
                WelcomeView(store: store)
            }
            Default {
                EmptyView()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            OnboardingView(store: .init(
                initialState: .welcome(.init()),
                reducer: Onboarding()
            ))
        }
    }
}
