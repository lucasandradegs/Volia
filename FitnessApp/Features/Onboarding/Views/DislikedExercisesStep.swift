import SwiftUI

struct DislikedExercisesStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
    ]

    var body: some View {
        OnboardingStepWrapper(
            title: "SEUS\nDISLIKES",
            subtitle: "A gente entende. Vamos adaptar seu plano.",
            stepTag: "Passo 6 de 9"
        ) {
            VStack(spacing: AppTheme.Spacing.lg) {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
                    ForEach(MuscleGroup.allCases) { muscle in
                        CompactSelectionCard(
                            title: muscle.rawValue,
                            icon: muscle.icon,
                            isSelected: viewModel.profile.dislikedMuscleGroups.contains(muscle)
                        ) {
                            toggleDisliked(muscle)
                        }
                    }
                }

                Text("Pule se você gosta de treinar tudo")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.disabled)
            }
        }
        .id("disliked")
    }

    private func toggleDisliked(_ muscle: MuscleGroup) {
        if let index = viewModel.profile.dislikedMuscleGroups.firstIndex(of: muscle) {
            viewModel.profile.dislikedMuscleGroups.remove(at: index)
        } else {
            viewModel.profile.dislikedMuscleGroups.append(muscle)
        }
    }
}

#Preview {
    DislikedExercisesStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
