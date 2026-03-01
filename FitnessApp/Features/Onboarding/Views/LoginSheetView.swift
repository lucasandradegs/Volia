import SwiftUI

struct LoginSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {

            // MARK: - Close Button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .frame(width: 30, height: 30)
                        .background(AppTheme.Colors.secondaryBackground)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Fechar")
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)

            // MARK: - Header
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("ENTRAR")
                    .font(AppTheme.Typography.displaySmall)
                    .tracking(AppTheme.Kerning.display)
                    .foregroundColor(AppTheme.Colors.label)

                Text("Acesse sua conta para continuar")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryLabel)
            }

            // MARK: - Login Options
            VStack(spacing: AppTheme.Spacing.sm) {
                loginButton(
                    icon: "apple.logo",
                    title: "Continuar com Apple",
                    style: .primary
                )

                loginButton(
                    icon: "g.circle.fill",
                    title: "Continuar com Google",
                    style: .secondary
                )

                loginButton(
                    icon: "envelope.fill",
                    title: "Continuar com E-mail",
                    style: .secondary
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppTheme.Spacing.xxl)

            // MARK: - Terms
            VStack(spacing: 2) {
                Text("Ao continuar, você concorda com os termos do Volia")
                    .foregroundColor(AppTheme.Colors.tertiaryLabel)

                HStack(spacing: 4) {
                    Text("Termos e Condições")
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .underline()

                    Text("e")
                        .foregroundColor(AppTheme.Colors.tertiaryLabel)

                    Text("Política de Privacidade")
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .underline()
                }
            }
            .font(AppTheme.Typography.caption)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.sm)

            Spacer()
        }
        .background(AppTheme.Colors.background)
    }

    // MARK: - Login Button

    private enum ButtonStyle {
        case primary, secondary
    }

    private func loginButton(icon: String, title: String, style: ButtonStyle) -> some View {
        Button {
            // TODO: Implementar autenticação
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .frame(width: 24)

                Text(title)
                    .font(AppTheme.Typography.headline)
                    .tracking(0.4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundColor(style == .primary ? AppTheme.Colors.background : AppTheme.Colors.label)
            .background(style == .primary ? AppTheme.Colors.label : AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sharp))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sharp)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                }
            }
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            LoginSheetView()
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
        }
}
