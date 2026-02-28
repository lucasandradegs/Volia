import SwiftUI

struct SecondaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(AppTheme.Colors.label)
                }
                Text(title.uppercased())
                    .font(AppTheme.Typography.headline)
                    .tracking(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppTheme.Colors.secondaryBackground)
            .foregroundColor(AppTheme.Colors.label)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sharp))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.sharp)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
        .accessibilityLabel(title)
        .animation(AppTheme.Animation.quick(reduceMotion: reduceMotion), value: isLoading)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        SecondaryButton("Criar manualmente") {}
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
