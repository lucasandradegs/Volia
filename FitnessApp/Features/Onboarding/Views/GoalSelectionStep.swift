import SwiftUI

struct GoalSelectionStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: "SEU\nOBJETIVO",
            subtitle: "Escolha o que mais importa pra você agora",
            stepTag: "Passo 1 de 8"
        ) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(WorkoutGoal.allCases) { goal in
                    SelectionCard(
                        title: goal.rawValue,
                        icon: goal.icon,
                        isSelected: viewModel.profile.goal == goal
                    ) {
                        viewModel.profile.goal = goal
                    }
                }
            }
        }
    }
}

#Preview {
    GoalSelectionStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
