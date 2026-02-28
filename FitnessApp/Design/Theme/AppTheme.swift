import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: Colors

    enum Colors {
        static let background = Color("AppBackground")
        static let secondaryBackground = Color("AppSecondaryBg")
        static let tertiaryBackground = Color("AppTertiaryBg")
        static let border = Color("AppBorder")
        static let label = Color("AppLabel")
        static let secondaryLabel = Color("AppLabelSecondary")
        static let tertiaryLabel = Color("AppLabelTertiary")
        static let disabled = Color("AppLabelDisabled")
        static let accent = Color("AppAccent")
        static let destructive = Color.red
    }

    // MARK: Typography

    enum Typography {
        // Bebas Neue — display
        static let display = Font.custom("BebasNeue-Regular", size: 72)
        static let displayMedium = Font.custom("BebasNeue-Regular", size: 48)
        static let displaySmall = Font.custom("BebasNeue-Regular", size: 28)

        // System — UI
        static let overline = Font.system(size: 11, weight: .medium)
        static let headline = Font.system(size: 14, weight: .semibold)
        static let body = Font.system(size: 14, weight: .light)
        static let caption = Font.system(size: 12, weight: .regular)
        static let metric = Font.custom("BebasNeue-Regular", size: 28)
    }

    // MARK: Kerning

    enum Kerning {
        static let overline: CGFloat = 1.5
        static let display: CGFloat = 0.5
        static let tag: CGFloat = 1.0
    }

    // MARK: Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: Radius

    enum Radius {
        static let sharp: CGFloat = 6
        static let card: CGFloat = 8
        static let medium: CGFloat = 12
    }

    // MARK: Animation

    enum Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
    }
}
