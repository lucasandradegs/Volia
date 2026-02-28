import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    var unit: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.tertiaryLabel)

            Spacer()

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(AppTheme.Typography.metric)
                    .foregroundColor(AppTheme.Colors.label)

                if let unit {
                    Text(unit)
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.tertiaryLabel)
                }
            }

            Text(title.uppercased())
                .font(AppTheme.Typography.overline)
                .tracking(AppTheme.Kerning.overline)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    HStack(spacing: AppTheme.Spacing.sm) {
        MetricCard(title: "Volume", value: "342", icon: "flame.fill", unit: "kg")
        MetricCard(title: "Séries", value: "24", icon: "arrow.triangle.2.circlepath")
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
