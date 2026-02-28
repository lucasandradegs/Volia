import Foundation

struct PlanDiagnostic {
    let splitName: String
    let splitFrequency: String
    let volumeRange: String
    let repRange: String
    let rpeRange: String
    let exercisesPerSession: String
    let restBetweenSets: String
    let estimatedCalories: Int
    let timeToResults: String
    let priorityMuscleGroups: [MuscleGroup]
    let recommendations: [String]
    let personalizedGreeting: String
    let goalIcon: String
}
