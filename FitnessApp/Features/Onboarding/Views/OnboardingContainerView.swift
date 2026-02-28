import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar
            HStack {
                if !viewModel.isFirstStep {
                    Button {
                        HapticManager.selection()
                        withAnimation(AppTheme.Animation.spring(reduceMotion: reduceMotion)) {
                            viewModel.previousStep()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(.body, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.label)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Voltar")
                }

                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, AppTheme.Spacing.md)
            .overlay {
                if !viewModel.isFirstStep {
                    StepIndicator(
                        currentStep: viewModel.currentStep - 1,
                        totalSteps: viewModel.totalSteps - 1
                    )
                }
            }

            // MARK: - Step Content
            Group {
                switch viewModel.currentStep {
                case 0: WelcomeStep()
                case 1: GoalSelectionStep(viewModel: viewModel)
                case 2: ExperienceLevelStep(viewModel: viewModel)
                case 3: BodyDataStep(viewModel: viewModel)
                case 4: TrainingPreferencesStep(viewModel: viewModel)
                case 5: DislikedExercisesStep(viewModel: viewModel)
                case 6: SensitiveAreasStep(viewModel: viewModel)
                case 7: AvailabilityStep(viewModel: viewModel)
                case 8: WorkoutSetupChoiceStep(viewModel: viewModel)
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(AppTheme.Animation.spring(reduceMotion: reduceMotion), value: viewModel.currentStep)

            // MARK: - Bottom Button
            if !viewModel.shouldHideBottomButton {
                VStack(spacing: AppTheme.Spacing.md) {
                    PrimaryButton(viewModel.buttonTitle) {
                        HapticManager.impact(.light)
                        if viewModel.isLastStep {
                            viewModel.completeOnboarding()
                        } else {
                            withAnimation(AppTheme.Animation.spring(reduceMotion: reduceMotion)) {
                                viewModel.nextStep()
                            }
                        }
                    }
                    .opacity(viewModel.canAdvance ? 1.0 : 0.3)
                    .disabled(!viewModel.canAdvance)

                    if !viewModel.isFirstStep && !viewModel.isLastStep {
                        Text("Você pode ajustar isso a qualquer momento")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.disabled)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    OnboardingContainerView()
}
