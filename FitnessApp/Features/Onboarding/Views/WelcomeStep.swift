import SwiftUI

struct WelcomeStep: View {
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40, weight: .thin))
                .foregroundColor(AppTheme.Colors.tertiaryLabel)
                .opacity(appeared ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
                .accessibilityHidden(true)

            VStack(spacing: AppTheme.Spacing.md) {
                Text("SEU\nTREINO")
                    .font(AppTheme.Typography.display)
                    .tracking(AppTheme.Kerning.display)
                    .foregroundColor(AppTheme.Colors.label)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 16))

                Text("DO SEU JEITO")
                    .font(AppTheme.Typography.display)
                    .tracking(AppTheme.Kerning.display)
                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 16))

                Text("Vamos criar um plano que respeita suas\npreferências, limitações e objetivos.")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, AppTheme.Spacing.sm)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 20))
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }
}

#Preview {
    WelcomeStep()
        .background(AppTheme.Colors.background)
}
