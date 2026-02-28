import Foundation
import os

final class UserPreferencesManager {
    static let shared = UserPreferencesManager()
    private let defaults = UserDefaults.standard
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FitnessApp", category: "UserPreferences")

    private init() {}

    // MARK: - Keys

    private enum Keys {
        static let onboardingProfile = "onboardingProfile"
        static let appState = "appState"
    }

    // MARK: - Onboarding Profile

    func saveOnboardingProfile(_ profile: OnboardingProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            defaults.set(data, forKey: Keys.onboardingProfile)
        } catch {
            logger.error("Falha ao salvar OnboardingProfile: \(error.localizedDescription)")
        }
    }

    func loadOnboardingProfile() -> OnboardingProfile? {
        guard let data = defaults.data(forKey: Keys.onboardingProfile) else { return nil }

        do {
            return try JSONDecoder().decode(OnboardingProfile.self, from: data)
        } catch {
            logger.error("Falha ao decodificar OnboardingProfile: \(error.localizedDescription)")
            defaults.removeObject(forKey: Keys.onboardingProfile)
            return nil
        }
    }

    // MARK: - App State

    func setAppState(_ state: AppState) {
        defaults.set(state.rawValue, forKey: Keys.appState)
    }

    func getAppState() -> AppState {
        guard let raw = defaults.string(forKey: Keys.appState) else { return .onboarding }
        return AppState(rawValue: raw) ?? .onboarding
    }

    // MARK: - Reset

    func clearAll() {
        defaults.removeObject(forKey: Keys.onboardingProfile)
        defaults.set(AppState.onboarding.rawValue, forKey: Keys.appState)
    }
}
