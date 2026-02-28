import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

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
                        .tint(AppTheme.Colors.background)
                }
                Text(title.uppercased())
                    .font(AppTheme.Typography.headline)
                    .tracking(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppTheme.Colors.label)
            .foregroundColor(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sharp))
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
        .animation(AppTheme.Animation.quick, value: isLoading)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        PrimaryButton("Build my plan") {}
        PrimaryButton("Loading...", isLoading: true) {}
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
