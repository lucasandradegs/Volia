import SwiftUI

struct DiagnosticView: View {
    @AppStorage("appState") private var appStateRaw: String = AppState.onboarding.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var diagnostic: PlanDiagnostic?
    @State private var heroAppeared = false
    @State private var cardsAppeared = [false, false, false]
    @State private var timelineAppeared = false
    @State private var tipsAppeared = false
    @State private var groupsAppeared = false
    @State private var ctaAppeared = false
    @State private var dotPulsing = false
    @State private var displayedCalories: Int = 0

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
    ]

    var body: some View {
        if let diagnostic {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                        badgeView
                        heroSection(diagnostic)
                        metricsGrid(diagnostic)
                        timelineSection(diagnostic)

                        if !diagnostic.recommendations.isEmpty {
                            recommendationsSection(diagnostic)
                        }

                        if !diagnostic.priorityMuscleGroups.isEmpty {
                            priorityGroupsSection(diagnostic)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.lg)
                }

                ctaSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background)
        } else {
            Color.clear
                .onAppear { loadDiagnostic() }
        }
    }

    // MARK: - Badge

    private var badgeView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppTheme.Colors.accent)
                .frame(width: 6, height: 6)
                .opacity(dotPulsing ? 1 : 0.3)

            Text("DIAGNÓSTICO COMPLETO")
                .font(AppTheme.Typography.smallLabel)
                .tracking(AppTheme.Kerning.tag)
                .foregroundStyle(AppTheme.Colors.tertiaryLabel)
        }
        .padding(.leading, 8)
        .padding(.trailing, 14)
        .padding(.vertical, 6)
        .overlay(Capsule().stroke(AppTheme.Colors.border, lineWidth: 1))
        .opacity(heroAppeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (heroAppeared ? 0 : 16))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                dotPulsing = true
            }
        }
    }

    // MARK: - Hero

    private func heroSection(_ diagnostic: PlanDiagnostic) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Image(systemName: diagnostic.goalIcon)
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(AppTheme.Colors.tertiaryLabel)
                .accessibilityHidden(true)

            Text("SEU PLANO\nPERSONALIZADO")
                .font(AppTheme.Typography.displayMedium)
                .kerning(AppTheme.Kerning.display)
                .foregroundStyle(AppTheme.Colors.label)
                .lineSpacing(-4)

            Text(diagnostic.personalizedGreeting)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.secondaryLabel)
                .lineSpacing(4)
                .padding(.top, AppTheme.Spacing.xs)
        }
        .opacity(heroAppeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (heroAppeared ? 0 : 16))
    }

    // MARK: - Metrics Grid

    private func metricsGrid(_ diagnostic: PlanDiagnostic) -> some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
            // Row 0
            MetricCard(title: "Divisão", value: diagnostic.splitName, icon: "calendar")
                .opacity(cardsAppeared[0] ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (cardsAppeared[0] ? 0 : 16))

            MetricCard(title: "Volume semanal", value: diagnostic.volumeRange, icon: "arrow.triangle.2.circlepath", unit: "séries/grupo")
                .opacity(cardsAppeared[0] ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (cardsAppeared[0] ? 0 : 16))

            // Row 1
            MetricCard(title: "Repetições", value: diagnostic.repRange, icon: "repeat", unit: "reps")
                .opacity(cardsAppeared[1] ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (cardsAppeared[1] ? 0 : 16))

            MetricCard(title: "Exercícios", value: diagnostic.exercisesPerSession, icon: "list.bullet", unit: "/sessão")
                .opacity(cardsAppeared[1] ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (cardsAppeared[1] ? 0 : 16))

            // Row 2
            MetricCard(title: "Calorias", value: "~\(displayedCalories)", icon: "flame.fill", unit: "kcal")
                .opacity(cardsAppeared[2] ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (cardsAppeared[2] ? 0 : 16))

            MetricCard(title: "Resultados em", value: diagnostic.timeToResults, icon: "chart.line.uptrend.xyaxis", unit: "semanas", accentValue: true)
                .opacity(cardsAppeared[2] ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (cardsAppeared[2] ? 0 : 16))
        }
    }

    // MARK: - Timeline

    private func timelineSection(_ diagnostic: PlanDiagnostic) -> some View {
        ResultsTimeline(timeToResults: diagnostic.timeToResults)
            .opacity(timelineAppeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (timelineAppeared ? 0 : 16))
    }

    // MARK: - Recommendations

    private func recommendationsSection(_ diagnostic: PlanDiagnostic) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(diagnostic.recommendations, id: \.self) { tip in
                HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(.subheadline))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .accessibilityHidden(true)

                    Text(tip)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.secondaryLabel)
                        .lineSpacing(4)
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
            }
        }
        .opacity(tipsAppeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (tipsAppeared ? 0 : 16))
    }

    // MARK: - Priority Groups

    private func priorityGroupsSection(_ diagnostic: PlanDiagnostic) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("GRUPOS PRIORITÁRIOS")
                .font(AppTheme.Typography.overline)
                .tracking(AppTheme.Kerning.overline)
                .foregroundStyle(AppTheme.Colors.secondaryLabel)

            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(diagnostic.priorityMuscleGroups) { group in
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: group.icon)
                            .font(.system(.caption2))
                            .accessibilityHidden(true)

                        Text(group.rawValue)
                            .font(AppTheme.Typography.smallLabel)
                            .tracking(0.5)
                    }
                    .foregroundStyle(AppTheme.Colors.label)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppTheme.Colors.border, lineWidth: 1))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(group.rawValue)
                }
            }
        }
        .opacity(groupsAppeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (groupsAppeared ? 0 : 16))
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            PrimaryButton("Criar conta e começar") {
                HapticManager.notification(.success)
                UserPreferencesManager.shared.setAppState(.authenticated)
            }

            SecondaryButton("Continuar sem conta") {
                HapticManager.impact(.light)
                UserPreferencesManager.shared.setAppState(.guest)
            }

            Text("Crie sua conta para salvar seu progresso\ne gerar fichas personalizadas com IA")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.disabled)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.lg)
        .opacity(ctaAppeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (ctaAppeared ? 0 : 16))
    }

    // MARK: - Load & Animate

    private func loadDiagnostic() {
        let profile = UserPreferencesManager.shared.loadOnboardingProfile() ?? OnboardingProfile()
        let engine = PlanDiagnosticEngine()
        diagnostic = engine.diagnose(profile)
        triggerAnimations()
    }

    private func triggerAnimations() {
        if reduceMotion {
            heroAppeared = true
            cardsAppeared = [true, true, true]
            timelineAppeared = true
            tipsAppeared = true
            groupsAppeared = true
            ctaAppeared = true
            displayedCalories = diagnostic?.estimatedCalories ?? 0
            return
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
            heroAppeared = true
        }

        for row in 0..<3 {
            let delay = 0.3 + Double(row) * 0.1
            withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                cardsAppeared[row] = true
            }
        }

        // Calorie counter rolls up
        withAnimation(.spring(duration: 0.8).delay(0.55)) {
            displayedCalories = diagnostic?.estimatedCalories ?? 0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            timelineAppeared = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.85)) {
            tipsAppeared = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.95)) {
            groupsAppeared = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.05)) {
            ctaAppeared = true
        }
    }
}

// MARK: - Results Timeline

private struct ResultsTimeline: View {
    let timeToResults: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var milestonesAppeared = [false, false, false, false]

    private struct Milestone: Identifiable {
        let id: String
        let week: String
        let label: String
        let description: String
        let isHighlight: Bool
    }

    private var milestones: [Milestone] {
        [
            Milestone(id: "adaptacao", week: "SEMANA 1-2", label: "Adaptação", description: "Eficiência neural melhora, forma se solidifica", isHighlight: false),
            Milestone(id: "evolucao", week: "SEMANA 3-4", label: "Evolução", description: "Primeiros ganhos de força, energia aumenta", isHighlight: false),
            Milestone(id: "resultados", week: "SEMANA \(timeToResults)", label: "Resultados", description: "Mudanças visíveis na composição corporal", isHighlight: true),
            Milestone(id: "consolidacao", week: "SEMANA 12+", label: "Consolidação", description: "Crescimento muscular significativo", isHighlight: false),
        ]
    }

    /// Index of the highlighted milestone — green coloring applies up to (and including) this index
    private var highlightIndex: Int {
        milestones.firstIndex(where: { $0.isHighlight }) ?? milestones.count - 1
    }

    /// Whether a milestone at the given index should use green (accent) coloring
    private func isGreen(_ index: Int) -> Bool {
        index <= highlightIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("CAMINHO ATÉ OS RESULTADOS")
                .font(AppTheme.Typography.overline)
                .tracking(AppTheme.Kerning.overline)
                .foregroundStyle(AppTheme.Colors.secondaryLabel)

            VStack(spacing: 0) {
                ForEach(Array(milestones.enumerated()), id: \.1.id) { index, milestone in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                        // Left: dot + vertical line
                        VStack(spacing: 0) {
                            // Fixed-size container for all dots — keeps alignment consistent
                            ZStack {
                                Circle()
                                    .fill(isGreen(index) ? AppTheme.Colors.accent : AppTheme.Colors.border)
                                    .frame(
                                        width: milestone.isHighlight ? 14 : 10,
                                        height: milestone.isHighlight ? 14 : 10
                                    )
                                    .shadow(
                                        color: milestone.isHighlight ? AppTheme.Colors.accent.opacity(0.3) : .clear,
                                        radius: milestone.isHighlight ? 6 : 0
                                    )
                            }
                            .frame(width: 14, height: 14)

                            if index < milestones.count - 1 {
                                // Line is green only if BOTH this dot and the next are green
                                Rectangle()
                                    .fill(isGreen(index + 1) ? AppTheme.Colors.accent : AppTheme.Colors.border)
                                    .frame(width: 1)
                                    .frame(minHeight: 32)
                                    .padding(.vertical, AppTheme.Spacing.xs)
                            }
                        }
                        .frame(width: 20, alignment: .top)

                        // Right: content
                        VStack(alignment: .leading, spacing: 3) {
                            Text(milestone.week)
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(1.0)
                                .foregroundStyle(milestone.isHighlight ? AppTheme.Colors.secondaryLabel : AppTheme.Colors.tertiaryLabel)

                            Text(milestone.label)
                                .font(milestone.isHighlight
                                    ? Font.custom("BebasNeue-Regular", size: 22, relativeTo: .title3)
                                    : .system(.subheadline, weight: .medium))
                                .foregroundStyle(milestone.isHighlight ? AppTheme.Colors.label : AppTheme.Colors.tertiaryLabel)
                                .tracking(milestone.isHighlight ? 0.5 : 0)

                            Text(milestone.description)
                                .font(.system(.caption, weight: .light))
                                .foregroundStyle(milestone.isHighlight ? AppTheme.Colors.secondaryLabel : AppTheme.Colors.tertiaryLabel)
                                .lineSpacing(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, index < milestones.count - 1 ? AppTheme.Spacing.md : 0)
                    }
                    .opacity(milestonesAppeared[index] ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (milestonesAppeared[index] ? 0 : 10))
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Caminho até os resultados: primeiros resultados em \(timeToResults) semanas")
        .onAppear { triggerMilestoneAnimations() }
    }

    private func triggerMilestoneAnimations() {
        if reduceMotion {
            milestonesAppeared = [true, true, true, true]
            return
        }
        for i in 0..<4 {
            withAnimation(.easeOut(duration: 0.4).delay(0.12 * Double(i) + 0.3)) {
                milestonesAppeared[i] = true
            }
        }
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

// MARK: - Previews

#Preview("Hipertrofia Iniciante") {
    DiagnosticView()
        .onAppear {
            var profile = OnboardingProfile()
            profile.goal = .hypertrophy
            profile.experienceLevel = .beginner
            profile.availableDays = 4
            profile.sessionDuration = 60
            profile.weight = 75
            profile.height = 178
            profile.age = 28
            UserPreferencesManager.shared.saveOnboardingProfile(profile)
        }
}

#Preview("Perda de Peso Avançado") {
    DiagnosticView()
        .onAppear {
            var profile = OnboardingProfile()
            profile.goal = .weightLoss
            profile.experienceLevel = .advanced
            profile.availableDays = 5
            profile.sessionDuration = 45
            profile.weight = 95
            profile.height = 170
            profile.age = 35
            profile.sensitiveAreas = [.back, .shoulders, .legs]
            UserPreferencesManager.shared.saveOnboardingProfile(profile)
        }
}
