import SwiftUI

struct CompactSelectionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(.body))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryLabel)
                    .frame(height: 22)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTheme.Typography.smallLabel)
                    .tracking(0.5)
                    .foregroundColor(AppTheme.Colors.label)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.border, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .animation(AppTheme.Animation.quick(reduceMotion: reduceMotion), value: isSelected)
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
