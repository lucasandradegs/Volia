import SwiftUI

struct SelectionCard: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryLabel)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.label)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.secondaryLabel)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.border, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(AppTheme.Animation.quick, value: isSelected)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.sm) {
        SelectionCard(title: "Ganhar massa muscular", subtitle: "Foco em hipertrofia", icon: "figure.strengthtraining.traditional", isSelected: true) {}
        SelectionCard(title: "Perder peso", subtitle: "Foco em queima calórica", icon: "flame.fill", isSelected: false) {}
        SelectionCard(title: "Saúde geral", icon: "heart.fill", isSelected: false) {}
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
