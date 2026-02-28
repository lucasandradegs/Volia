import SwiftUI

struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? AppTheme.Colors.label : AppTheme.Colors.disabled)
                    .frame(width: index == currentStep ? 18 : 6, height: 6)
                    .animation(AppTheme.Animation.spring(reduceMotion: reduceMotion), value: currentStep)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Passo \(currentStep + 1) de \(totalSteps)")
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.xl) {
        StepIndicator(currentStep: 0, totalSteps: 7)
        StepIndicator(currentStep: 3, totalSteps: 7)
        StepIndicator(currentStep: 6, totalSteps: 7)
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.background)
}
