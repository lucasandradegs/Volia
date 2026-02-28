import SwiftUI

struct ExperienceLevelStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: "SEU\nNÍVEL",
            subtitle: "Seja honesto — isso nos ajuda a montar o plano certo pra você",
            stepTag: "Passo 2 de 7"
        ) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(ExperienceLevel.allCases) { level in
                    SelectionCard(
                        title: level.rawValue,
                        subtitle: level.subtitle,
                        icon: level.icon,
                        isSelected: viewModel.profile.experienceLevel == level
                    ) {
                        viewModel.profile.experienceLevel = level
                    }
                }
            }
        }
    }
}

#Preview {
    ExperienceLevelStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
