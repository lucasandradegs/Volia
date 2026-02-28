import SwiftUI

struct CompactSelectionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryLabel)
                    .frame(height: 22)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(AppTheme.Colors.label)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
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
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
        CompactSelectionCard(title: "Peito", icon: "figure.arms.open", isSelected: true) {}
        CompactSelectionCard(title: "Costas", icon: "figure.cross.training", isSelected: false) {}
        CompactSelectionCard(title: "Pernas", icon: "figure.run", isSelected: true) {}
        CompactSelectionCard(title: "Ombros", icon: "figure.boxing", isSelected: false) {}
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
