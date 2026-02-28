import SwiftUI

struct OnboardingStepWrapper<Content: View>: View {
    let title: String
    let subtitle: String
    var stepTag: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                if let stepTag {
                    Text(stepTag.uppercased())
                        .font(AppTheme.Typography.overline)
                        .tracking(AppTheme.Kerning.tag)
                        .foregroundColor(AppTheme.Colors.tertiaryLabel)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.Colors.disabled, lineWidth: 1)
                        )
                }

                Text(title)
                    .font(AppTheme.Typography.displayMedium)
                    .tracking(AppTheme.Kerning.display)
                    .foregroundColor(AppTheme.Colors.label)
                    .lineSpacing(-4)

                Text(subtitle)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.secondaryLabel)
                    .lineSpacing(4)
            }
            .padding(.bottom, AppTheme.Spacing.xl)

            content()

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview {
    OnboardingStepWrapper(
        title: "SEU\nOBJETIVO",
        subtitle: "Escolha o que mais importa pra você agora",
        stepTag: "Passo 1 de 7"
    ) {
        SelectionCard(title: "Ganhar massa", icon: "figure.strengthtraining.traditional", isSelected: true) {}
        SelectionCard(title: "Perder peso", icon: "flame.fill", isSelected: false) {}
    }
    .background(AppTheme.Colors.background)
}
