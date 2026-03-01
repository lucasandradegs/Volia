import SwiftUI

struct WelcomeStep: View {
    @State private var appeared = false
    @State private var currentPage = 0

    // Page 2: Notifications
    @State private var visibleNotifications = 0
    @State private var notificationsExpanded = false

    // Page 3: Line Chart
    @State private var chartTrim: CGFloat = 0
    @State private var chartMetricShown = false

    // Page 4: Activity Rings
    @State private var ringsProgress: [CGFloat] = [0, 0, 0]
    @State private var ringsCardShown = false

    // Auto-advance
    @State private var autoAdvanceTimer: Timer?
    private let autoAdvanceInterval: TimeInterval = 5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Paged Cards Area
            TabView(selection: $currentPage) {
                featuresPage.tag(0)
                notificationsPage.tag(1)
                chartPage.tag(2)
                activityRingsPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // MARK: - Page Indicator
            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? AppTheme.Colors.accent : AppTheme.Colors.border)
                        .frame(width: currentPage == index ? 20 : 6, height: 6)
                        .animation(AppTheme.Animation.quick(reduceMotion: reduceMotion), value: currentPage)
                }
            }
            .padding(.top, AppTheme.Spacing.sm)

            Spacer()

            // MARK: - Title + Subtitle
            VStack(spacing: AppTheme.Spacing.md) {
                VStack(spacing: -6) {
                    Text("SEU")
                        .foregroundColor(AppTheme.Colors.label)
                    Text("TREINO")
                        .foregroundColor(AppTheme.Colors.label)
                    Text("DO SEU JEITO")
                        .foregroundColor(AppTheme.Colors.tertiaryLabel)
                }
                .font(AppTheme.Typography.displayMedium)
                .tracking(AppTheme.Kerning.display)
                .multilineTextAlignment(.center)

                Text("Vamos criar um plano que respeita suas\npreferências, limitações e objetivos.")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.md)
        }
        .onAppear {
            resetAll()
            if reduceMotion {
                appeared = true
                triggerPageInstant(currentPage)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation { appeared = true }
                    triggerPage(currentPage)
                }
            }
            startAutoAdvance()
        }
        .onDisappear {
            stopAutoAdvance()
        }
        .onChange(of: currentPage) { _, newPage in
            resetAll()
            if reduceMotion {
                appeared = true
                triggerPageInstant(newPage)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation { appeared = true }
                    triggerPage(newPage)
                }
            }
            startAutoAdvance()
        }
    }

    // MARK: - Auto-Advance

    private func startAutoAdvance() {
        stopAutoAdvance()
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: autoAdvanceInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentPage = (currentPage + 1) % pageCount
                }
            }
        }
    }

    private func stopAutoAdvance() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
    }

    // MARK: - Reset & Trigger

    private func resetAll() {
        appeared = false
        visibleNotifications = 0
        notificationsExpanded = false
        chartTrim = 0
        chartMetricShown = false
        ringsProgress = [0, 0, 0]
        ringsCardShown = false
    }

    private func triggerPageInstant(_ page: Int) {
        switch page {
        case 1:
            visibleNotifications = notifications.count
            notificationsExpanded = true
        case 2:
            chartTrim = 1
            chartMetricShown = true
        case 3:
            ringsProgress = [0.85, 0.65, 0.92]
            ringsCardShown = true
        default: break
        }
    }

    private func triggerPage(_ page: Int) {
        switch page {
        case 1: triggerNotifications()
        case 2: triggerChart()
        case 3: triggerRings()
        default: break
        }
    }

    // MARK: - Page 1: Features Grid

    private var featuresPage: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            featureCard(
                icon: "figure.strengthtraining.traditional",
                title: "Treinos Personalizados",
                subtitle: "Planos adaptados ao seu nível e objetivos"
            )

            HStack(spacing: AppTheme.Spacing.sm) {
                iconCard(icon: "chart.line.uptrend.xyaxis")
                featureCard(
                    icon: "bolt.fill",
                    title: "Evolução Real",
                    subtitle: "Acompanhe cada conquista"
                )
            }
            .fixedSize(horizontal: false, vertical: true)
            .opacity(appeared ? 1 : 0)
            .offset(x: reduceMotion ? 0 : (appeared ? 0 : 40))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.15), value: appeared)

            HStack(spacing: AppTheme.Spacing.sm) {
                featureCard(
                    icon: "brain.head.profile.fill",
                    title: "Plano Inteligente",
                    subtitle: "IA que entende você"
                )
                iconCard(icon: "flame.fill")
            }
            .fixedSize(horizontal: false, vertical: true)
            .opacity(appeared ? 1 : 0)
            .offset(x: reduceMotion ? 0 : (appeared ? 0 : -40))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.3), value: appeared)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Page 2: Notifications (Sonner Stack)

    private let notifications: [(icon: String, title: String, subtitle: String, time: String)] = [
        ("dumbbell.fill", "Hora do treino!", "Seu treino de Peito e Tríceps está pronto", "1 h"),
        ("trophy.fill", "Nova conquista!", "Você completou 7 dias seguidos", "15 min"),
        ("chart.line.uptrend.xyaxis", "Progresso semanal", "Você superou sua meta em 12%", "2 min"),
        ("sparkles", "Plano atualizado", "Intensidade ajustada com base no seu progresso", "agora")
    ]

    private let cardHeight: CGFloat = 58
    private let cardSpacing: CGFloat = 8

    private var notificationsPage: some View {
        ZStack(alignment: .top) {
            ForEach(0..<notifications.count, id: \.self) { index in
                let isVisible = index < visibleNotifications
                let depth = isVisible ? (visibleNotifications - 1 - index) : 0
                let stackedOffset = CGFloat(depth) * 14
                let expandedOffset = CGFloat(notifications.count - 1 - index) * (cardHeight + cardSpacing)

                notificationCard(
                    icon: notifications[index].icon,
                    title: notifications[index].title,
                    subtitle: notifications[index].subtitle,
                    time: notifications[index].time
                )
                .frame(height: cardHeight)
                .scaleEffect(
                    x: notificationsExpanded ? 1.0 : (isVisible ? 1.0 - CGFloat(depth) * 0.05 : 0.95),
                    y: 1.0, anchor: .top
                )
                .offset(y: isVisible ? (notificationsExpanded ? expandedOffset : stackedOffset) : -30)
                .opacity(isVisible ? (notificationsExpanded ? 1.0 : 1.0 - Double(depth) * 0.2) : 0)
                .zIndex(Double(index))
                .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.78), value: visibleNotifications)
                .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.82), value: notificationsExpanded)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func triggerNotifications() {
        for i in 0..<notifications.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i + 1) * 0.55) {
                withAnimation { visibleNotifications = i + 1 }
            }
        }
        let expandDelay = Double(notifications.count + 1) * 0.55 + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + expandDelay) {
            withAnimation { notificationsExpanded = true }
        }
    }

    // MARK: - Page 3: Line Chart (Progresso Semanal)

    private let chartPoints: [CGFloat] = [0.15, 0.25, 0.22, 0.38, 0.42, 0.55, 0.52, 0.68, 0.72, 0.85]

    private var chartPage: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Chart Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CARGA TOTAL")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.secondaryLabel)
                        .kerning(AppTheme.Kerning.overline)
                    Text("Últimas 10 semanas")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryLabel)
                }
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.accent)
                    Text("+34%")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .opacity(chartMetricShown ? 1 : 0)
                .offset(y: chartMetricShown ? 0 : 8)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: chartMetricShown)
            }

            // Chart
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                // Grid lines
                ForEach(0..<4, id: \.self) { i in
                    let y = h * CGFloat(i) / 3.0
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y))
                    }
                    .stroke(AppTheme.Colors.border.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                }

                // Area fill
                Path { path in
                    let points = chartPoints.enumerated().map { (i, v) in
                        CGPoint(x: CGFloat(i) / CGFloat(chartPoints.count - 1) * w, y: h - v * h)
                    }
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let curr = points[i]
                        let midX = (prev.x + curr.x) / 2
                        path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
                    }
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.accent.opacity(0.25), AppTheme.Colors.accent.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .mask(
                    Rectangle()
                        .scaleEffect(x: chartTrim, y: 1, anchor: .leading)
                )

                // Line
                Path { path in
                    let points = chartPoints.enumerated().map { (i, v) in
                        CGPoint(x: CGFloat(i) / CGFloat(chartPoints.count - 1) * w, y: h - v * h)
                    }
                    path.move(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let curr = points[i]
                        let midX = (prev.x + curr.x) / 2
                        path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
                    }
                }
                .trim(from: 0, to: chartTrim)
                .stroke(AppTheme.Colors.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // End dot
                if chartTrim >= 1.0 {
                    let lastPoint = CGPoint(
                        x: w,
                        y: h - chartPoints.last! * h
                    )
                    Circle()
                        .fill(AppTheme.Colors.accent)
                        .frame(width: 8, height: 8)
                        .position(lastPoint)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 140)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )

            // Metric Cards
            HStack(spacing: AppTheme.Spacing.sm) {
                metricPill(label: "VOLUME", value: "12.4k", unit: "kg")
                metricPill(label: "SESSÕES", value: "28", unit: "treinos")
                metricPill(label: "RECORDE", value: "105", unit: "kg")
            }
            .opacity(chartMetricShown ? 1 : 0)
            .offset(y: chartMetricShown ? 0 : 12)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: chartMetricShown)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func triggerChart() {
        withAnimation(.easeInOut(duration: 1.2)) { chartTrim = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { chartMetricShown = true }
        }
    }

    // MARK: - Page 4: Activity Rings

    private let ringTargets: [(label: String, value: CGFloat, icon: String, color: Color)] = [
        ("Treinos", 0.85, "dumbbell.fill", Color(red: 1.0, green: 0.27, blue: 0.37)),
        ("Calorias", 0.65, "flame.fill", Color(red: 0.55, green: 1.0, blue: 0.35)),
        ("Metas", 0.92, "target", Color(red: 0.35, green: 0.78, blue: 1.0))
    ]

    private var activityRingsPage: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Rings
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    let size: CGFloat = 150 - CGFloat(index) * 40
                    let target = ringTargets[index]

                    // Track
                    Circle()
                        .stroke(target.color.opacity(0.15), lineWidth: 10)
                        .frame(width: size, height: size)

                    // Progress
                    Circle()
                        .trim(from: 0, to: ringsProgress[index])
                        .stroke(target.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(-90))
                        .animation(
                            reduceMotion ? nil : .easeOut(duration: 0.9).delay(Double(index) * 0.15),
                            value: ringsProgress[index]
                        )
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )

            // Metric cards
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<3, id: \.self) { index in
                    let target = ringTargets[index]
                    VStack(spacing: 6) {
                        Image(systemName: target.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(target.color)
                            .frame(width: 20, height: 20)

                        Text("\(Int(target.value * 100))%")
                            .font(AppTheme.Typography.displaySmall)
                            .foregroundColor(AppTheme.Colors.label)

                        Text(target.label)
                            .font(AppTheme.Typography.smallLabel)
                            .foregroundColor(AppTheme.Colors.secondaryLabel)
                            .kerning(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                }
            }
            .opacity(ringsCardShown ? 1 : 0)
            .offset(y: ringsCardShown ? 0 : 12)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: ringsCardShown)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func triggerRings() {
        withAnimation {
            ringsProgress = [0.85, 0.65, 0.92]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { ringsCardShown = true }
        }
    }

    // MARK: - Shared Components

    private func notificationCard(icon: String, title: String, subtitle: String, time: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 34, height: 34)
                .background(AppTheme.Colors.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sharp))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.label)
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryLabel)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(time)
                .font(AppTheme.Typography.smallLabel)
                .foregroundColor(AppTheme.Colors.tertiaryLabel)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private func featureCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.label)
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
            }
            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.md)
        .frame(minHeight: 56)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private func iconCard(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 24, weight: .light))
            .foregroundColor(AppTheme.Colors.accent)
            .frame(width: 72)
            .frame(maxHeight: .infinity)
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .accessibilityHidden(true)
    }

    private func metricPill(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(AppTheme.Typography.smallLabel)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
                .kerning(1)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppTheme.Typography.displaySmall)
                    .foregroundColor(AppTheme.Colors.label)
                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(AppTheme.Colors.tertiaryLabel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}

#Preview {
    WelcomeStep()
        .background(AppTheme.Colors.background)
}
