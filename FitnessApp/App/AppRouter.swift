import SwiftUI

struct AppRouter: View {
    @AppStorage("appState") private var appStateRaw: String = AppState.onboarding.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var appState: AppState {
        AppState(rawValue: appStateRaw) ?? .onboarding
    }

    var body: some View {
        Group {
            switch appState {
            case .onboarding:
                OnboardingContainerView()
            case .awaitingAccount:
                DiagnosticView()
            case .authenticated, .guest:
                MainTabView()
            }
        }
        .animation(AppTheme.Animation.standard(reduceMotion: reduceMotion), value: appStateRaw)
    }
}

#Preview("Onboarding") {
    AppRouter()
}

#Preview("Diagnóstico") {
    AppRouter()
        .onAppear {
            UserDefaults.standard.set(AppState.awaitingAccount.rawValue, forKey: "appState")
        }
}

#Preview("Main App") {
    AppRouter()
        .onAppear {
            UserDefaults.standard.set(AppState.authenticated.rawValue, forKey: "appState")
        }
}
