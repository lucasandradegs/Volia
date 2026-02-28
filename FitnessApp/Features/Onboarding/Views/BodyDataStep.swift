import SwiftUI

struct BodyDataStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var activeTab: Tab = .age

    private enum Tab: String, CaseIterable {
        case age = "Idade"
        case body = "Corpo"
    }

    // MARK: - BMI

    private var bmi: Double {
        let h = Double(viewModel.profile.height) / 100.0
        guard h > 0 else { return 0 }
        return Double(viewModel.profile.weight) / (h * h)
    }

    private var bmiCategory: BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .healthy
        case 25..<30: return .overweight
        default: return .obese
        }
    }

    var body: some View {
        OnboardingStepWrapper(
            title: "SOBRE\nVOCÊ",
            subtitle: "Usamos esses dados para personalizar intensidade e recuperação.",
            stepTag: "Passo 3 de 8"
        ) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {

                // MARK: - Tab Selector
                tabSelector

                // MARK: - Content
                Group {
                    switch activeTab {
                    case .age:
                        agePanel
                    case .body:
                        bodyPanel
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(AppTheme.Animation.spring(reduceMotion: reduceMotion), value: activeTab)
            }
        }
        .onAppear {
            viewModel.bodyDataShowsContinue = (activeTab == .body)
        }
        .onChange(of: activeTab) { _, newTab in
            viewModel.bodyDataShowsContinue = (newTab == .body)
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    HapticManager.selection()
                    withAnimation(AppTheme.Animation.quick(reduceMotion: reduceMotion)) {
                        activeTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(Font.custom("BebasNeue-Regular", size: 22, relativeTo: .title2))
                            .tracking(1)
                            .foregroundColor(activeTab == tab
                                             ? AppTheme.Colors.label
                                             : AppTheme.Colors.tertiaryLabel)

                        Rectangle()
                            .fill(activeTab == tab
                                  ? AppTheme.Colors.label
                                  : AppTheme.Colors.border)
                            .frame(height: activeTab == tab ? 2 : 1)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Aba \(tab.rawValue)")
                .accessibilityAddTraits(activeTab == tab ? [.isSelected] : [])
            }
        }
    }

    // MARK: - Age Panel

    private var agePanel: some View {
        VStack(spacing: AppTheme.Spacing.lg) {

            // Big display
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(viewModel.profile.age)")
                    .font(Font.custom("BebasNeue-Regular", size: 72, relativeTo: .largeTitle))
                    .tracking(AppTheme.Kerning.display)
                    .foregroundColor(AppTheme.Colors.label)
                    .contentTransition(.numericText())
                    .animation(AppTheme.Animation.quick(reduceMotion: reduceMotion), value: viewModel.profile.age)

                Text("anos")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.profile.age) anos de idade")

            // Progress bar + markers
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    let progress = CGFloat(viewModel.profile.age - 1) / CGFloat(99)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.Colors.secondaryBackground)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.Colors.accent)
                            .frame(width: progress * geo.size.width, height: 4)
                            .animation(AppTheme.Animation.quick(reduceMotion: reduceMotion), value: viewModel.profile.age)
                    }
                }
                .frame(height: 4)

                // Markers
                GeometryReader { geo in
                    let markers: [(Int, String)] = [(18, "18"), (30, "30"), (50, "50")]
                    ForEach(markers, id: \.0) { age, label in
                        let pos = CGFloat(age - 1) / 99.0 * geo.size.width
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(AppTheme.Colors.tertiaryLabel)
                            .tracking(0.8)
                            .position(x: pos, y: 10)
                    }
                }
                .frame(height: 20)
            }

            // Slider
            AgeSlider(value: $viewModel.profile.age, reduceMotion: reduceMotion)
                .frame(height: 44)

            // "Next: Corpo" button
            Button {
                HapticManager.selection()
                withAnimation(AppTheme.Animation.spring(reduceMotion: reduceMotion)) {
                    activeTab = .body
                }
            } label: {
                Text("Avançar: Corpo")
                    .font(AppTheme.Typography.headline)
                    .tracking(0.8)
                    .foregroundColor(AppTheme.Colors.secondaryLabel)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.sharp)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Avançar para a aba Corpo")
        }
    }

    // MARK: - Body Panel

    private var bodyPanel: some View {
        VStack(spacing: AppTheme.Spacing.lg) {

            // Wheel pickers
            HStack(spacing: 0) {
                // Weight picker
                VStack(spacing: 4) {
                    Text("PESO")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .kerning(AppTheme.Kerning.overline)

                    Picker("Peso", selection: $viewModel.profile.weight) {
                        ForEach(30...200, id: \.self) { kg in
                            Text("\(kg) kg")
                                .font(Font.custom("BebasNeue-Regular", size: 22, relativeTo: .title3))
                                .tag(kg)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .accessibilityLabel("Peso em quilogramas")
                    .accessibilityValue("\(viewModel.profile.weight) kg")
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(AppTheme.Colors.border)
                    .frame(width: 1)
                    .padding(.vertical, AppTheme.Spacing.md)

                // Height picker
                VStack(spacing: 4) {
                    Text("ALTURA")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .kerning(AppTheme.Kerning.overline)

                    Picker("Altura", selection: $viewModel.profile.height) {
                        ForEach(130...220, id: \.self) { cm in
                            Text("\(cm) cm")
                                .font(Font.custom("BebasNeue-Regular", size: 22, relativeTo: .title3))
                                .tag(cm)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .accessibilityLabel("Altura em centímetros")
                    .accessibilityValue("\(viewModel.profile.height) cm")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )

            // BMI Card
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ÍNDICE DE MASSA CORPORAL")
                        .font(AppTheme.Typography.smallLabel)
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .kerning(1)

                    Text("Calculado automaticamente")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryLabel)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", bmi))
                        .font(Font.custom("BebasNeue-Regular", size: 36, relativeTo: .title))
                        .foregroundColor(bmiCategory.color)
                        .contentTransition(.numericText())
                        .animation(AppTheme.Animation.quick(reduceMotion: reduceMotion), value: bmi)

                    Text(bmiCategory.label)
                        .font(AppTheme.Typography.smallLabel)
                        .foregroundColor(bmiCategory.color.opacity(0.7))
                        .kerning(1)
                }
            }
            .padding(18)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("IMC: \(String(format: "%.1f", bmi)), \(bmiCategory.label)")

            // Summary row
            HStack(spacing: AppTheme.Spacing.sm) {
                SummaryMiniCard(label: "IDADE", value: "\(viewModel.profile.age)", unit: "anos")
                SummaryMiniCard(label: "PESO", value: "\(viewModel.profile.weight)", unit: "kg")
                SummaryMiniCard(label: "ALTURA", value: "\(viewModel.profile.height)", unit: "cm")
            }
        }
    }
}

// MARK: - BMI Category

private enum BMICategory {
    case underweight, healthy, overweight, obese

    var label: String {
        switch self {
        case .underweight: return "Abaixo do peso"
        case .healthy: return "Saudável"
        case .overweight: return "Sobrepeso"
        case .obese: return "Obesidade"
        }
    }

    var color: Color {
        switch self {
        case .underweight: return Color(red: 0.42, green: 0.62, blue: 1.0)
        case .healthy: return Color(red: 0.42, green: 1.0, blue: 0.62)
        case .overweight: return Color(red: 1.0, green: 0.82, blue: 0.42)
        case .obese: return Color(red: 1.0, green: 0.42, blue: 0.42)
        }
    }
}

// MARK: - Summary Mini Card

private struct SummaryMiniCard: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(AppTheme.Typography.smallLabel)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
                .kerning(1)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(Font.custom("BebasNeue-Regular", size: 24, relativeTo: .title2))
                    .foregroundColor(AppTheme.Colors.label)

                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value) \(unit)")
    }
}

// MARK: - Age Slider

private struct AgeSlider: View {
    @Binding var value: Int
    let reduceMotion: Bool
    private let range = 1...100

    var body: some View {
        GeometryReader { geo in
            let steps = range.upperBound - range.lowerBound
            let progress = CGFloat(value - range.lowerBound) / CGFloat(steps)
            let trackWidth = geo.size.width - 16
            let thumbX = progress * trackWidth + 8

            ZStack(alignment: .leading) {
                // Track background
                Rectangle()
                    .fill(AppTheme.Colors.border)
                    .frame(height: 2)
                    .cornerRadius(1)

                // Track fill
                Rectangle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: max(0, thumbX - 8), height: 2)
                    .cornerRadius(1)

                // Thumb
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 16, height: 16)
                    .padding(14)
                    .contentShape(Circle().scale(2.75))
                    .offset(x: thumbX - 22)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let raw = gesture.location.x / geo.size.width
                        let clamped = max(0, min(1, raw))
                        let newValue = range.lowerBound + Int(round(clamped * CGFloat(steps)))
                        if newValue != value {
                            withAnimation(reduceMotion ? nil : .interactiveSpring()) {
                                value = newValue
                            }
                            HapticManager.selection()
                        }
                    }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Idade")
        .accessibilityValue("\(value) anos")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if value < 100 { value += 1; HapticManager.selection() }
            case .decrement:
                if value > 1 { value -= 1; HapticManager.selection() }
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    BodyDataStep(viewModel: OnboardingViewModel())
        .background(AppTheme.Colors.background)
}
