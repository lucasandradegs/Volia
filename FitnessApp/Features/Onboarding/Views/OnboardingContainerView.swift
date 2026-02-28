import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar
            HStack {
                if !viewModel.isFirstStep {
                    Button {
                        HapticManager.selection()
                        withAnimation(AppTheme.Animation.spring) {
                            viewModel.previousStep()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.label)
                    }
                }

                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .overlay {
                if !viewModel.isFirstStep {
                    StepIndicator(
                        currentStep: viewModel.currentStep - 1,
                        totalSteps: viewModel.totalSteps - 1
                    )
                }
            }

            // MARK: - Step Content
            TabView(selection: $viewModel.currentStep) {
                WelcomeStep()
                    .tag(0)

                GoalSelectionStep(viewModel: viewModel)
                    .tag(1)

                ExperienceLevelStep(viewModel: viewModel)
                    .tag(2)

                TrainingPreferencesStep(viewModel: viewModel)
                    .tag(3)

                DislikedExercisesStep(viewModel: viewModel)
                    .tag(4)

                SensitiveAreasStep(viewModel: viewModel)
                    .tag(5)

                AvailabilityStep(viewModel: viewModel)
                    .tag(6)

                WorkoutSetupChoiceStep(viewModel: viewModel)
                    .tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(AppTheme.Animation.spring, value: viewModel.currentStep)
            .onChange(of: viewModel.currentStep) { oldValue, newValue in
                // Só bloqueia avanço — retroceder é sempre permitido
                if newValue > oldValue && !viewModel.canAdvanceFrom(step: oldValue) {
                    viewModel.currentStep = oldValue
                }
            }

            // MARK: - Bottom Button
            VStack(spacing: AppTheme.Spacing.md) {
                PrimaryButton(viewModel.buttonTitle) {
                    HapticManager.impact(.light)
                    if viewModel.isLastStep {
                        viewModel.completeOnboarding()
                    } else {
                        withAnimation(AppTheme.Animation.spring) {
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
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    OnboardingContainerView()
}
