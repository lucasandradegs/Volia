import SwiftUI

struct WorkoutSetupChoiceStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private var isAISelected: Bool {
        viewModel.profile.workoutSetupChoice == .ai
    }

    private var isManualSelected: Bool {
        viewModel.profile.workoutSetupChoice == .manual
    }

    var body: some View {
        OnboardingStepWrapper(
            title: "SEU\nPLANO",
            subtitle: "Você pode mudar isso depois, sem stress.",
            stepTag: "Passo 7 de 7"
        ) {
            VStack(spacing: AppTheme.Spacing.sm) {
                // Card IA com badge
                Button {
                    HapticManager.selection()
                    viewModel.profile.workoutSetupChoice = .ai
                } label: {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(isAISelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryLabel)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Text("Montar para mim")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.Colors.label)

                                Text("RECOMENDADO")
                                    .font(.system(size: 9, weight: .semibold))
                                    .kerning(AppTheme.Kerning.overline)
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.Colors.accent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sharp))
                            }

                            Text("Ficha personalizada com base no seu perfil")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryLabel)
                        }

                        Spacer()
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                            .stroke(isAISelected ? AppTheme.Colors.accent : AppTheme.Colors.border, lineWidth: isAISelected ? 1.5 : 1)
                    )
                }
                .buttonStyle(.plain)

                // Card Manual
                SelectionCard(
                    title: "Criar manualmente",
                    subtitle: "Prefiro cadastrar meus próprios exercícios",
                    icon: "pencil.and.list.clipboard",
                    isSelected: isManualSelected
                ) {
                    viewModel.profile.workoutSetupChoice = .manual
                }
            }
        }
        .animation(AppTheme.Animation.quick, value: viewModel.profile.workoutSetupChoice)
    }
}

#Preview {
    WorkoutSetupChoiceStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
