import SwiftUI

struct GenderSelectionStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: "SEU\nGÊNERO",
            subtitle: "Usamos essa informação para personalizar seus cálculos e treinos",
            stepTag: "Passo 1 de 9"
        ) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(Gender.allCases) { gender in
                    SelectionCard(
                        title: gender.rawValue,
                        subtitle: gender.subtitle,
                        icon: gender.icon,
                        isSelected: viewModel.profile.gender == gender
                    ) {
                        viewModel.profile.gender = gender
                    }
                }
            }
        }
    }
}

#Preview {
    GenderSelectionStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
