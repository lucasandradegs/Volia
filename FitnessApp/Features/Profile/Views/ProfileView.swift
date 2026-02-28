import SwiftUI

struct ProfileView: View {
    @AppStorage("appState") private var appStateRaw: String = AppState.onboarding.rawValue
    @State private var showResetConfirmation = false

    private var profile: OnboardingProfile? {
        UserPreferencesManager.shared.loadOnboardingProfile()
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Seu Perfil") {
                    profileRow(label: "Objetivo", value: profile?.goal?.rawValue)
                    profileRow(label: "Nível", value: profile?.experienceLevel?.rawValue)
                    profileRow(label: "Idade", value: profile.map { "\($0.age) anos" })
                    profileRow(label: "Peso", value: profile.map { "\($0.weight) kg" })
                    profileRow(label: "Altura", value: profile.map { "\($0.height) cm" })
                    profileRow(label: "Dias por semana", value: profile.map { "\($0.availableDays)" })
                    profileRow(label: "Duração", value: profile.map { "\($0.sessionDuration) min" })
                    profileRow(label: "Equipamento", value: profile?.equipmentAvailable?.rawValue)
                }

                Section {
                    Button(role: .destructive) {
                        HapticManager.notification(.warning)
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Refazer Onboarding")
                        }
                    }
                } header: {
                    Text("Configurações")
                }
            }
            .navigationTitle("Perfil")
            .confirmationDialog(
                "Tem certeza que deseja refazer o onboarding?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Refazer", role: .destructive) {
                    UserPreferencesManager.shared.clearAll()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Seus dados de perfil serão apagados.")
            }
        }
    }

    // MARK: - Components

    private func profileRow(label: String, value: String?) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(AppTheme.Colors.secondaryLabel)
            Spacer()
            Text(value ?? "—")
                .foregroundStyle(AppTheme.Colors.label)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ProfileView()
}
