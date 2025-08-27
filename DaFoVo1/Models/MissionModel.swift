//
//  MissionModel.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Mission System
//

import Foundation

// MARK: - Mission
struct Mission: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var difficulty: DifficultyLevel
    var rewards: Int
    var educationalContent: String
    var challengeType: ChallengeType
    var isCompleted: Bool
    var isLocked: Bool = false
    var prerequisites: [String] = []
    var timeLimit: TimeInterval? = nil
    var startDate: Date? = nil
    
    enum ChallengeType: String, Codable, CaseIterable {
        case budgeting = "Budgeting"
        case investing = "Investing"
        case saving = "Saving"
        case debtManagement = "Debt Management"
        case riskManagement = "Risk Management"
        case emergencyPlanning = "Emergency Planning"
        
        var icon: String {
            switch self {
            case .budgeting: return "chart.pie.fill"
            case .investing: return "chart.line.uptrend.xyaxis"
            case .saving: return "banknote.fill"
            case .debtManagement: return "creditcard.fill"
            case .riskManagement: return "shield.fill"
            case .emergencyPlanning: return "exclamationmark.triangle.fill"
            }
        }
        
        var color: String {
            switch self {
            case .budgeting: return "blue"
            case .investing: return "green"
            case .saving: return "orange"
            case .debtManagement: return "red"
            case .riskManagement: return "purple"
            case .emergencyPlanning: return "yellow"
            }
        }
    }
    
    var adjustedRewards: Int {
        return Int(Double(rewards) * difficulty.multiplier)
    }
    
    var isAvailable: Bool {
        return !isLocked && !isCompleted
    }
    
    var estimatedDuration: String {
        switch difficulty {
        case .beginner: return "5-10 min"
        case .intermediate: return "10-15 min"
        case .advanced: return "15-25 min"
        case .expert: return "25-40 min"
        }
    }
}

// MARK: - Mission Challenge
struct MissionChallenge: Identifiable {
    let id = UUID()
    var question: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String
    var points: Int
    
    var isMultipleChoice: Bool {
        return options.count > 1
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var category: AchievementCategory = .general
    var rarity: AchievementRarity = .common
    
    enum AchievementCategory: String, Codable, CaseIterable {
        case general = "General"
        case missions = "Missions"
        case learning = "Learning"
        case progress = "Progress"
        case special = "Special"
    }
    
    enum AchievementRarity: String, Codable, CaseIterable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: String {
            switch self {
            case .common: return "gray"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "gold"
            }
        }
    }
    
    mutating func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
}

// MARK: - Financial Scenario
struct FinancialScenario: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var initialBudget: Int
    var monthlyIncome: Int
    var expenses: [Expense]
    var goals: [FinancialGoal]
    var duration: Int // in months
    var difficulty: DifficultyLevel
    
    struct Expense: Identifiable, Codable {
        let id = UUID()
        var name: String
        var amount: Int
        var category: ExpenseCategory
        var isFixed: Bool
        
        enum ExpenseCategory: String, Codable, CaseIterable {
            case housing = "Housing"
            case food = "Food"
            case transportation = "Transportation"
            case utilities = "Utilities"
            case entertainment = "Entertainment"
            case healthcare = "Healthcare"
            case education = "Education"
            case savings = "Savings"
            case other = "Other"
            
            var icon: String {
                switch self {
                case .housing: return "house.fill"
                case .food: return "fork.knife"
                case .transportation: return "car.fill"
                case .utilities: return "bolt.fill"
                case .entertainment: return "tv.fill"
                case .healthcare: return "cross.fill"
                case .education: return "book.fill"
                case .savings: return "banknote.fill"
                case .other: return "ellipsis.circle.fill"
                }
            }
        }
    }
    
    struct FinancialGoal: Identifiable, Codable {
        let id = UUID()
        var name: String
        var targetAmount: Int
        var currentAmount: Int = 0
        var deadline: Date
        var priority: Priority
        
        enum Priority: String, Codable, CaseIterable {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
            case critical = "Critical"
        }
        
        var progress: Double {
            return Double(currentAmount) / Double(targetAmount)
        }
        
        var isCompleted: Bool {
            return currentAmount >= targetAmount
        }
    }
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable {
    let id = UUID()
    var question: String
    var answers: [String]
    var correctAnswerIndex: Int
    var explanation: String
    var category: Mission.ChallengeType
    var difficulty: DifficultyLevel
    var points: Int
    
    var isCorrect: (Int) -> Bool {
        return { selectedIndex in
            return selectedIndex == correctAnswerIndex
        }
    }
}

