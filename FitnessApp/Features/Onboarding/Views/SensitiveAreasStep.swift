import SwiftUI

struct SensitiveAreasStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
    ]

    var body: some View {
        OnboardingStepWrapper(
            title: "ÁREAS\nSENSÍVEIS",
            subtitle: "Queremos que você treine seguro. Vamos pegar leve onde precisar.",
            stepTag: "Passo 6 de 8"
        ) {
            VStack(spacing: AppTheme.Spacing.lg) {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
                    ForEach(MuscleGroup.allCases) { area in
                        CompactSelectionCard(
                            title: area.rawValue,
                            icon: area.icon,
                            isSelected: viewModel.profile.sensitiveAreas.contains(area)
                        ) {
                            toggleSensitive(area)
                        }
                    }
                }

                Text("Pule se você não tem limitações")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.disabled)
            }
        }
        .id("sensitive")
    }

    private func toggleSensitive(_ area: MuscleGroup) {
        if let index = viewModel.profile.sensitiveAreas.firstIndex(of: area) {
            viewModel.profile.sensitiveAreas.remove(at: index)
        } else {
            viewModel.profile.sensitiveAreas.append(area)
        }
    }
}

#Preview {
    SensitiveAreasStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
