import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showLoginSheet = false

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
                case 1: GenderSelectionStep(viewModel: viewModel)
                case 2: GoalSelectionStep(viewModel: viewModel)
                case 3: ExperienceLevelStep(viewModel: viewModel)
                case 4: BodyDataStep(viewModel: viewModel)
                case 5: TrainingPreferencesStep(viewModel: viewModel)
                case 6: DislikedExercisesStep(viewModel: viewModel)
                case 7: SensitiveAreasStep(viewModel: viewModel)
                case 8: AvailabilityStep(viewModel: viewModel)
                case 9: WorkoutSetupChoiceStep(viewModel: viewModel)
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
                VStack(spacing: AppTheme.Spacing.xs) {
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

                    if viewModel.isFirstStep {
                        Button {
                            showLoginSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Já tem uma conta?")
                                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
                                Text("Entrar")
                                    .foregroundColor(AppTheme.Colors.accent)
                            }
                            .font(AppTheme.Typography.body)
                        }
                        .frame(minHeight: 44)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.background)
        .sheet(isPresented: $showLoginSheet) {
            LoginSheetView()
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    OnboardingContainerView()
}
