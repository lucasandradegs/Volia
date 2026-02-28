import Foundation

struct PlanDiagnosticEngine {

    func diagnose(_ profile: OnboardingProfile) -> PlanDiagnostic {
        let goal = profile.goal ?? .generalHealth
        let level = profile.experienceLevel ?? .beginner
        let days = profile.availableDays
        let duration = profile.sessionDuration
        let weight = profile.weight
        let height = profile.height

        let split = computeSplit(days: days, level: level)
        let volume = computeVolume(level: level, goal: goal)
        let reps = computeRepRange(goal: goal)
        let rpe = computeRPE(level: level, goal: goal)
        let exercises = computeExercisesPerSession(duration: duration)
        let rest = computeRestBetweenSets(duration: duration)
        let bmi = computeBMI(weight: weight, height: height)
        let calories = computeCalories(weight: weight, duration: duration, rpe: rpe)
        let time = computeTimeToResults(goal: goal, level: level)
        let priority = computePriorityGroups(
            disliked: profile.dislikedMuscleGroups,
            sensitive: profile.sensitiveAreas
        )
        let recommendations = computeRecommendations(
            bmi: bmi,
            age: profile.age,
            days: days,
            goal: goal,
            sensitiveCount: profile.sensitiveAreas.count
        )
        let greeting = computeGreeting(goal: goal, level: level)

        return PlanDiagnostic(
            splitName: split,
            splitFrequency: "\(days)x por semana",
            volumeRange: volume,
            repRange: reps,
            rpeRange: rpe.display,
            exercisesPerSession: exercises,
            restBetweenSets: rest,
            estimatedCalories: calories,
            timeToResults: time,
            priorityMuscleGroups: priority,
            recommendations: recommendations,
            personalizedGreeting: greeting,
            goalIcon: goal.icon
        )
    }

    // MARK: - Split

    private func computeSplit(days: Int, level: ExperienceLevel) -> String {
        switch days {
        case ...2:
            return "Full Body"
        case 3:
            switch level {
            case .beginner: return "Full Body"
            case .intermediate: return "Full Body / PPL"
            case .advanced: return "Push/Pull/Legs"
            }
        case 4:
            return "Upper/Lower"
        case 5:
            switch level {
            case .beginner: return "Upper/Lower + 1"
            case .intermediate, .advanced: return "PPL + Upper/Lower"
            }
        default:
            switch level {
            case .beginner, .intermediate: return "PPL"
            case .advanced: return "PPL (2x)"
            }
        }
    }

    // MARK: - Volume

    private func computeVolume(level: ExperienceLevel, goal: WorkoutGoal) -> String {
        switch (level, goal) {
        case (.beginner, .hypertrophy): return "8-10"
        case (.beginner, .weightLoss): return "6-8"
        case (.beginner, .strength): return "6-8"
        case (.beginner, .generalHealth): return "6-8"
        case (.beginner, .endurance): return "8-10"
        case (.intermediate, .hypertrophy): return "14-16"
        case (.intermediate, .weightLoss): return "10-12"
        case (.intermediate, .strength): return "10-12"
        case (.intermediate, .generalHealth): return "10-12"
        case (.intermediate, .endurance): return "12-14"
        case (.advanced, .hypertrophy): return "18-22"
        case (.advanced, .weightLoss): return "14-16"
        case (.advanced, .strength): return "12-16"
        case (.advanced, .generalHealth): return "12-14"
        case (.advanced, .endurance): return "16-18"
        }
    }

    // MARK: - Rep Range

    private func computeRepRange(goal: WorkoutGoal) -> String {
        switch goal {
        case .hypertrophy: return "8-12"
        case .weightLoss: return "12-15"
        case .strength: return "3-6"
        case .generalHealth: return "10-15"
        case .endurance: return "15-20"
        }
    }

    // MARK: - RPE

    private func computeRPE(level: ExperienceLevel, goal: WorkoutGoal) -> (low: Int, high: Int, display: String) {
        switch (level, goal) {
        case (.beginner, .hypertrophy): return (6, 7, "6-7")
        case (.beginner, .weightLoss): return (5, 6, "5-6")
        case (.beginner, .strength): return (6, 7, "6-7")
        case (.beginner, .generalHealth): return (5, 6, "5-6")
        case (.beginner, .endurance): return (5, 6, "5-6")
        case (.intermediate, .hypertrophy): return (7, 8, "7-8")
        case (.intermediate, .weightLoss): return (6, 7, "6-7")
        case (.intermediate, .strength): return (7, 8, "7-8")
        case (.intermediate, .generalHealth): return (6, 7, "6-7")
        case (.intermediate, .endurance): return (6, 7, "6-7")
        case (.advanced, .hypertrophy): return (8, 9, "8-9")
        case (.advanced, .weightLoss): return (7, 8, "7-8")
        case (.advanced, .strength): return (8, 9, "8-9")
        case (.advanced, .generalHealth): return (7, 8, "7-8")
        case (.advanced, .endurance): return (7, 8, "7-8")
        }
    }

    // MARK: - Exercises Per Session

    private func computeExercisesPerSession(duration: Int) -> String {
        switch duration {
        case ...30: return "4-5"
        case ...45: return "5-6"
        case ...60: return "6-8"
        default: return "8-10"
        }
    }

    // MARK: - Rest Between Sets

    private func computeRestBetweenSets(duration: Int) -> String {
        switch duration {
        case ...30: return "60-90s"
        case ...45: return "90-120s"
        case ...60: return "90-120s"
        default: return "120-180s"
        }
    }

    // MARK: - BMI

    private func computeBMI(weight: Int, height: Int) -> Double {
        let h = Double(height) / 100.0
        guard h > 0 else { return 0 }
        return Double(weight) / (h * h)
    }

    // MARK: - Calories

    private func computeCalories(weight: Int, duration: Int, rpe: (low: Int, high: Int, display: String)) -> Int {
        let base = Double(weight) * 0.07 * Double(duration)
        let rpeMid = Double(rpe.low + rpe.high) / 2.0

        let factor: Double
        if rpeMid <= 6.0 {
            factor = 0.85
        } else if rpeMid <= 8.0 {
            factor = 1.0
        } else {
            factor = 1.15
        }

        let adjusted = base * factor
        return Int(round(adjusted / 10.0)) * 10
    }

    // MARK: - Time to Results

    private func computeTimeToResults(goal: WorkoutGoal, level: ExperienceLevel) -> String {
        switch (goal, level) {
        case (.hypertrophy, .beginner): return "8-12"
        case (.hypertrophy, .intermediate): return "6-8"
        case (.hypertrophy, .advanced): return "4-6"
        case (.weightLoss, .beginner): return "4-6"
        case (.weightLoss, .intermediate): return "3-5"
        case (.weightLoss, .advanced): return "2-4"
        case (.strength, .beginner): return "6-8"
        case (.strength, .intermediate): return "4-6"
        case (.strength, .advanced): return "3-5"
        case (.generalHealth, .beginner): return "3-4"
        case (.generalHealth, .intermediate): return "2-3"
        case (.generalHealth, .advanced): return "2-3"
        case (.endurance, .beginner): return "4-6"
        case (.endurance, .intermediate): return "3-5"
        case (.endurance, .advanced): return "2-4"
        }
    }

    // MARK: - Priority Muscle Groups

    private func computePriorityGroups(disliked: [MuscleGroup], sensitive: [MuscleGroup]) -> [MuscleGroup] {
        let excluded = Set(disliked).union(Set(sensitive))
        return MuscleGroup.allCases.filter { !excluded.contains($0) }
    }

    // MARK: - Recommendations

    private func computeRecommendations(bmi: Double, age: Int, days: Int, goal: WorkoutGoal, sensitiveCount: Int) -> [String] {
        var tips: [String] = []

        if bmi > 30 {
            tips.append("Incluir caminhada leve nos dias de descanso")
        }

        if bmi < 18.5 && goal == .hypertrophy {
            tips.append("Atenção à alimentação — superávit calórico é essencial")
        }

        if age > 45 {
            tips.append("Aquecimento articular de 5-10 min recomendado")
        }

        if days <= 2 && goal == .hypertrophy {
            tips.append("Considere aumentar para 3x/sem quando possível")
        }

        if sensitiveCount > 2 {
            tips.append("Exercícios alternativos serão priorizados para suas áreas sensíveis")
        }

        return tips
    }

    // MARK: - Personalized Greeting

    private func computeGreeting(goal: WorkoutGoal, level: ExperienceLevel) -> String {
        switch (goal, level) {
        case (.hypertrophy, .beginner):
            return "Seu objetivo é ganhar massa muscular — e você está no lugar certo pra começar.\n\nPreparamos tudo pensando em quem está começando: progressão segura, volume adequado e foco no que importa."

        case (.hypertrophy, .intermediate):
            return "Seu objetivo é ganhar massa muscular — e o caminho está claro.\n\nCom sua experiência, otimizamos volume e intensidade pra você continuar evoluindo."

        case (.hypertrophy, .advanced):
            return "Seu objetivo é ganhar massa muscular — cada detalhe conta nesse nível.\n\nSeu nível pede precisão. Ajustamos cada variável pra extrair o máximo dos seus treinos."

        case (.weightLoss, .beginner):
            return "Você quer perder peso com saúde — e esse é o primeiro passo mais importante.\n\nPreparamos tudo pensando em quem está começando: progressão segura, volume adequado e foco no que importa."

        case (.weightLoss, .intermediate):
            return "Você quer perder peso com saúde. Montamos o plano certo pra isso.\n\nCom sua experiência, otimizamos volume e intensidade pra maximizar sua queima calórica."

        case (.weightLoss, .advanced):
            return "Você quer perder peso e já sabe o caminho. Vamos otimizar.\n\nSeu nível pede precisão. Ajustamos cada variável pra extrair o máximo de cada sessão."

        case (.strength, .beginner):
            return "Força é o seu foco — e você vai se surpreender com o quanto pode ganhar no início.\n\nPreparamos tudo pensando em quem está começando: cargas progressivas, técnica e segurança."

        case (.strength, .intermediate):
            return "Força é o seu foco. Cada sessão vai te deixar mais forte.\n\nCom sua experiência, otimizamos intensidade e volume pra você continuar progredindo."

        case (.strength, .advanced):
            return "Força é o seu foco — e nesse nível, cada detalhe faz diferença.\n\nSeu nível pede precisão. Ajustamos periodização e intensidade pro máximo resultado."

        case (.generalHealth, .beginner):
            return "Cuidar da saúde é o melhor investimento. E você já deu o primeiro passo.\n\nPreparamos tudo pensando em quem está começando: exercícios acessíveis, ritmo adequado e consistência."

        case (.generalHealth, .intermediate):
            return "Cuidar da saúde é o melhor investimento — e você já está no caminho.\n\nCom sua experiência, montamos um plano equilibrado pra manter você ativo e saudável."

        case (.generalHealth, .advanced):
            return "Cuidar da saúde é o melhor investimento — e você já tem a base.\n\nSeu nível permite um plano completo e variado. Otimizamos tudo pra manter qualidade de vida."

        case (.endurance, .beginner):
            return "Resistência se constrói com consistência — e você já está aqui.\n\nPreparamos tudo pensando em quem está começando: volumes progressivos e descanso adequado."

        case (.endurance, .intermediate):
            return "Resistência se constrói com consistência — e você já tem uma base sólida.\n\nCom sua experiência, ajustamos volume e intensidade pra levar sua resistência ao próximo nível."

        case (.endurance, .advanced):
            return "Resistência é o seu forte — vamos refinar.\n\nSeu nível pede periodização precisa. Otimizamos cada variável pra performance máxima."
        }
    }
}
