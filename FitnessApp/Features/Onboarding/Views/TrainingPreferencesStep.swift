import SwiftUI

struct TrainingPreferencesStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: "SEU\nESPAÇO",
            subtitle: "Isso influencia quais exercícios vamos sugerir",
            stepTag: "Passo 4 de 8"
        ) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(EquipmentType.allCases) { equipment in
                    SelectionCard(
                        title: equipment.rawValue,
                        subtitle: equipment.subtitle,
                        icon: equipment.icon,
                        isSelected: viewModel.profile.equipmentAvailable == equipment
                    ) {
                        viewModel.profile.equipmentAvailable = equipment
                    }
                }
            }
        }
    }
}

#Preview {
    TrainingPreferencesStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
