import SwiftUI

// MARK: - View Extensions

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }

    func hideKeyboard() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
