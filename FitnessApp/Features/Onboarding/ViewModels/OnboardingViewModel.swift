import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentStep: Int = 0
    @Published var profile = OnboardingProfile()

    let totalSteps = 8

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

    var canAdvance: Bool {
        canAdvanceFrom(step: currentStep)
    }

    func canAdvanceFrom(step: Int) -> Bool {
        switch step {
        case 0:
            return true
        case 1:
            return profile.goal != nil
        case 2:
            return profile.experienceLevel != nil
        case 3:
            return profile.equipmentAvailable != nil
        case 4:
            return true // Disliked muscles é opcional
        case 5:
            return true // Sensitive areas é opcional
        case 6:
            return true // Availability tem valores padrão
        case 7:
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
        // Será implementado na Etapa 4 (persistência)
    }
}
