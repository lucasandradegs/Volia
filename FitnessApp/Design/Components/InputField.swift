import SwiftUI

struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @State private var isPasswordVisible = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label.uppercased())
                .font(AppTheme.Typography.overline)
                .tracking(AppTheme.Kerning.overline)
                .foregroundColor(AppTheme.Colors.secondaryLabel)

            HStack(spacing: AppTheme.Spacing.sm) {
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.label)
                .focused($isFocused)

                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(AppTheme.Colors.tertiaryLabel)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, 14)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sharp))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.sharp)
                    .stroke(isFocused ? AppTheme.Colors.label : AppTheme.Colors.border, lineWidth: 1)
            )
            .animation(AppTheme.Animation.quick, value: isFocused)
        }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        InputField(label: "Email", placeholder: "your@email.com", text: .constant(""), keyboardType: .emailAddress)
        InputField(label: "Password", placeholder: "Your password", text: .constant(""), isSecure: true)
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
