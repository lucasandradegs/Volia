import SwiftUI

struct AppRouter: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingContainerView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
    }
}

#Preview("Onboarding") {
    AppRouter()
}

#Preview("Main App") {
    AppRouter()
        .onAppear {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
}
