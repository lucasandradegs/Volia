import Foundation

// MARK: - Onboarding Profile

struct OnboardingProfile: Codable {
    var goal: WorkoutGoal?
    var experienceLevel: ExperienceLevel?
    var availableDays: Int = 3
    var sessionDuration: Int = 45
    var dislikedMuscleGroups: [MuscleGroup] = []
    var sensitiveAreas: [MuscleGroup] = []
    var equipmentAvailable: EquipmentType?
    var workoutSetupChoice: WorkoutSetupChoice?
}

// MARK: - Enums

enum WorkoutGoal: String, Codable, CaseIterable, Identifiable {
    case hypertrophy = "Ganhar massa muscular"
    case weightLoss = "Perder peso"
    case strength = "Ganhar força"
    case generalHealth = "Saúde geral"
    case endurance = "Resistência"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hypertrophy: return "figure.strengthtraining.traditional"
        case .weightLoss: return "flame.fill"
        case .strength: return "bolt.fill"
        case .generalHealth: return "heart.fill"
        case .endurance: return "figure.run"
        }
    }
}

enum ExperienceLevel: String, Codable, CaseIterable, Identifiable {
    case beginner = "Iniciante"
    case intermediate = "Intermediário"
    case advanced = "Avançado"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .beginner: return "Estou começando agora ou voltando depois de um tempo parado"
        case .intermediate: return "Já treino com consistência e conheço os exercícios básicos"
        case .advanced: return "Treino há bastante tempo e busco otimizar meus resultados"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "figure.walk"
        case .intermediate: return "figure.strengthtraining.traditional"
        case .advanced: return "figure.highintensity.intervaltraining"
        }
    }
}

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Peito"
    case back = "Costas"
    case shoulders = "Ombros"
    case biceps = "Bíceps"
    case triceps = "Tríceps"
    case legs = "Pernas"
    case core = "Core"
    case glutes = "Glúteos"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.cross.training"
        case .shoulders: return "figure.boxing"
        case .biceps: return "figure.strengthtraining.traditional"
        case .triceps: return "figure.cooldown"
        case .legs: return "figure.run"
        case .core: return "figure.core.training"
        case .glutes: return "figure.step.training"
        }
    }
}

enum EquipmentType: String, Codable, CaseIterable, Identifiable {
    case fullGym = "Academia completa"
    case homeBasic = "Home gym básica"
    case bodyweightOnly = "Peso corporal"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .fullGym: return "Tenho acesso a todos os equipamentos"
        case .homeBasic: return "Tenho alguns equipamentos em casa"
        case .bodyweightOnly: return "Treino sem equipamento"
        }
    }

    var icon: String {
        switch self {
        case .fullGym: return "building.2.fill"
        case .homeBasic: return "house.fill"
        case .bodyweightOnly: return "figure.flexibility"
        }
    }
}

enum WorkoutSetupChoice: String, Codable {
    case ai = "Montar para mim"
    case manual = "Quero criar manualmente"
}
