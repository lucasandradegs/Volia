import SwiftUI

struct AvailabilityStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let durations: [(value: Int, label: String, desc: String)] = [
        (30, "30", "Focado"),
        (45, "45", "Equilibrado"),
        (60, "60", "Completo"),
        (90, "90", "Intenso")
    ]

    private let dayLabels = ["SEG", "TER", "QUA", "QUI", "SEX", "SAB", "DOM"]
    private let barHeights: [CGFloat] = [32, 40, 36, 48, 32, 44, 36]

    private var commitmentLabel: String {
        switch viewModel.profile.availableDays {
        case 1...2: return "Leve"
        case 3...4: return "Moderado"
        case 5...6: return "Intenso"
        default: return "Elite"
        }
    }

    private var commitmentSub: String {
        switch viewModel.profile.availableDays {
        case 1...2: return "Fácil de manter"
        case 3...4: return "Ótimo equilíbrio"
        case 5...6: return "Dedicação séria"
        default: return "Compromisso total"
        }
    }

    private var totalMinutes: Int {
        viewModel.profile.availableDays * viewModel.profile.sessionDuration
    }

    var body: some View {
        OnboardingStepWrapper(
            title: "SUA\nROTINA",
            subtitle: "Vamos montar seu plano em torno da sua vida real — não o contrário.",
            stepTag: "Passo 7 de 8"
        ) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {

                // MARK: - Dias por semana
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {

                    HStack(alignment: .bottom) {
                        Text("DIAS POR SEMANA")
                            .font(AppTheme.Typography.overline)
                            .foregroundColor(AppTheme.Colors.secondaryLabel)
                            .kerning(AppTheme.Kerning.overline)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(viewModel.profile.availableDays)")
                                    .font(AppTheme.Typography.displaySmall)
                                    .foregroundColor(AppTheme.Colors.label)
                                Text("/ 7")
                                    .font(AppTheme.Typography.smallLabel)
                                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
                                    .kerning(1)
                            }
                            Text("\(commitmentLabel) · \(commitmentSub)")
                                .font(AppTheme.Typography.smallLabel)
                                .foregroundColor(AppTheme.Colors.secondaryLabel)
                                .kerning(0.8)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(viewModel.profile.availableDays) de 7 dias por semana. \(commitmentLabel), \(commitmentSub)")

                    // Bar chart
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<7, id: \.self) { i in
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(i < viewModel.profile.availableDays
                                          ? AppTheme.Colors.accent
                                          : AppTheme.Colors.secondaryBackground)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: barHeights[i])
                                    .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7), value: viewModel.profile.availableDays)

                                Text(dayLabels[i])
                                    .font(AppTheme.Typography.smallLabel)
                                    .kerning(0.8)
                                    .foregroundColor(i < viewModel.profile.availableDays
                                                     ? AppTheme.Colors.label
                                                     : AppTheme.Colors.tertiaryLabel)
                                    .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: viewModel.profile.availableDays)
                            }
                            .contentShape(Rectangle())
                            .frame(minHeight: 44)
                            .onTapGesture {
                                HapticManager.selection()
                                withAnimation(reduceMotion ? nil : .spring(response: 0.3)) {
                                    viewModel.profile.availableDays = i + 1
                                }
                            }
                            .accessibilityLabel("\(dayLabels[i]), \(i < viewModel.profile.availableDays ? "selecionado" : "não selecionado")")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                    .accessibilityElement(children: .contain)

                    // Slider
                    DaysSlider(value: $viewModel.profile.availableDays, reduceMotion: reduceMotion)
                        .frame(height: 44)
                        .padding(.top, 4)
                }

                // MARK: - Duração por sessão
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("DURAÇÃO DA SESSÃO")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .kerning(AppTheme.Kerning.overline)

                    HStack(spacing: 8) {
                        ForEach(durations, id: \.value) { d in
                            Button {
                                HapticManager.selection()
                                withAnimation(AppTheme.Animation.quick(reduceMotion: reduceMotion)) {
                                    viewModel.profile.sessionDuration = d.value
                                }
                            } label: {
                                DurationCard(
                                    label: d.label,
                                    desc: d.desc,
                                    isSelected: viewModel.profile.sessionDuration == d.value,
                                    reduceMotion: reduceMotion
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(d.label) minutos, \(d.desc)")
                            .accessibilityAddTraits(viewModel.profile.sessionDuration == d.value ? [.isSelected] : [])
                        }
                    }
                }

                // MARK: - Summary Pill
                if viewModel.profile.sessionDuration > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SEU VOLUME SEMANAL")
                                .font(AppTheme.Typography.smallLabel)
                                .foregroundColor(AppTheme.Colors.secondaryLabel)
                                .kerning(1)
                            Text("\(viewModel.profile.availableDays) sessões · \(viewModel.profile.sessionDuration) min cada")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.label)
                        }
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(totalMinutes)")
                                .font(AppTheme.Typography.displaySmall)
                                .foregroundColor(AppTheme.Colors.label)
                            Text("min/sem")
                                .font(AppTheme.Typography.smallLabel)
                                .foregroundColor(AppTheme.Colors.secondaryLabel)
                        }
                    }
                    .padding(18)
                    .background(AppTheme.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Volume semanal: \(totalMinutes) minutos por semana. \(viewModel.profile.availableDays) sessões de \(viewModel.profile.sessionDuration) minutos")
                }
            }
        }
    }
}

// MARK: - Duration Card
private struct DurationCard: View {
    let label: String
    let desc: String
    let isSelected: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 40, weight: .thin, design: .default))
                .foregroundColor(isSelected ? AppTheme.Colors.label : AppTheme.Colors.tertiaryLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("min")
                .font(AppTheme.Typography.smallLabel)
                .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryLabel)
                .kerning(1)

            Text(desc)
                .font(AppTheme.Typography.smallLabel)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.Colors.secondaryBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.border, lineWidth: isSelected ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Custom Slider
private struct DaysSlider: View {
    @Binding var value: Int
    let reduceMotion: Bool
    private let range = 1...7

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

                // Thumb — visual 16pt mas área de toque 44pt
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 16, height: 16)
                    .padding(14) // expande touch target para 44pt
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
        .accessibilityLabel("Dias por semana")
        .accessibilityValue("\(value) dias")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if value < 7 { value += 1; HapticManager.selection() }
            case .decrement:
                if value > 1 { value -= 1; HapticManager.selection() }
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    AvailabilityStep(viewModel: OnboardingViewModel())
}
