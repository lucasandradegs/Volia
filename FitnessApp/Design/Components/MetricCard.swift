import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    var unit: String? = nil
    var inverted: Bool = false
    var accentValue: Bool = false

    private var bgColor: Color {
        inverted ? AppTheme.Colors.label : AppTheme.Colors.secondaryBackground
    }

    private var valueColor: Color {
        if accentValue { return AppTheme.Colors.accent }
        return inverted ? AppTheme.Colors.background : AppTheme.Colors.label
    }

    private var subtleColor: Color {
        inverted ? AppTheme.Colors.disabled : AppTheme.Colors.tertiaryLabel
    }

    private var titleColor: Color {
        inverted ? AppTheme.Colors.disabled : AppTheme.Colors.secondaryLabel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(.subheadline))
                .foregroundColor(accentValue ? AppTheme.Colors.accent : subtleColor)
                .accessibilityHidden(true)

            Spacer()

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(AppTheme.Typography.metric)
                    .foregroundColor(valueColor)
                    .contentTransition(.numericText(countsDown: false))

                if let unit {
                    Text(unit)
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(subtleColor)
                }
            }

            Text(title.uppercased())
                .font(AppTheme.Typography.overline)
                .tracking(AppTheme.Kerning.overline)
                .foregroundColor(titleColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(inverted ? Color.clear : AppTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(unit ?? "")")
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.sm) {
        HStack(spacing: AppTheme.Spacing.sm) {
            MetricCard(title: "Volume", value: "342", icon: "flame.fill", unit: "kg")
            MetricCard(title: "Séries", value: "24", icon: "arrow.triangle.2.circlepath", inverted: true)
        }
        HStack(spacing: AppTheme.Spacing.sm) {
            MetricCard(title: "Calorias", value: "~390", icon: "flame.fill", unit: "kcal", inverted: true)
            MetricCard(title: "Resultados", value: "6-8", icon: "chart.line.uptrend.xyaxis", unit: "semanas", accentValue: true)
        }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
