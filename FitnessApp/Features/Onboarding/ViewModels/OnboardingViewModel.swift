import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentStep: Int = 0
    @Published var profile = OnboardingProfile()
    @Published var bodyDataShowsContinue: Bool = false

    let totalSteps = 10

    // MARK: - Navigation

    var progress: Double {
        Double(currentStep) / Double(totalSteps - 1)
    }

    var isFirstStep: Bool {
        currentStep == 0
    }

    var isLastStep: Bool {
        currentStep == totalSteps - 1
    }

    var buttonTitle: String {
        isLastStep ? "Começar" : "Continuar"
    }

    var shouldHideBottomButton: Bool {
        currentStep == 4 && !bodyDataShowsContinue
    }

    var canAdvance: Bool {
        canAdvanceFrom(step: currentStep)
    }

    func canAdvanceFrom(step: Int) -> Bool {
        switch step {
        case 0:
            return true
        case 1:
            return profile.gender != nil
        case 2:
            return profile.goal != nil
        case 3:
            return profile.experienceLevel != nil
        case 4:
            return true // Body data tem valores padrão
        case 5:
            return profile.equipmentAvailable != nil
        case 6:
            return true // Disliked muscles é opcional
        case 7:
            return true // Sensitive areas é opcional
        case 8:
            return true // Availability tem valores padrão
        case 9:
            return profile.workoutSetupChoice != nil
        default:
            return false
        }
    }

    func nextStep() {
        guard canAdvance, currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    // MARK: - Completion

    func completeOnboarding() {
        UserPreferencesManager.shared.saveOnboardingProfile(profile)
        UserPreferencesManager.shared.setAppState(.awaitingAccount)
    }
}
