//
//  ResourceModel.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Resource Management
//

import Foundation

// MARK: - User Progress
struct UserProgress: Codable {
    var credits: Int = 100 // Начинаем с небольшой суммы для новичков
    var level: Int = 1
    var experience: Int = 0
    var completedMissions: Set<String> = []
    var unlockedAchievements: Set<String> = []
    var currentDifficulty: DifficultyLevel = .beginner
    var hasCompletedOnboarding: Bool = false
    var lastPlayDate: Date = Date()
    
    mutating func addCredits(_ amount: Int) {
        credits += amount
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    private mutating func checkLevelUp() {
        let requiredExp = level * 100
        if experience >= requiredExp {
            level += 1
            experience -= requiredExp
        }
    }
    
    mutating func completeMission(_ missionId: String) {
        completedMissions.insert(missionId)
    }
    
    mutating func unlockAchievement(_ achievementId: String) {
        unlockedAchievements.insert(achievementId)
    }
}

// MARK: - Game Resources
struct GameResource: Identifiable, Codable {
    let id = UUID()
    var name: String
    var amount: Int
    var maxCapacity: Int
    var icon: String
    var description: String
    
    var percentage: Double {
        return Double(amount) / Double(maxCapacity)
    }
    
    var isAtCapacity: Bool {
        return amount >= maxCapacity
    }
    
    mutating func add(_ value: Int) {
        amount = min(amount + value, maxCapacity)
    }
    
    mutating func subtract(_ value: Int) -> Bool {
        if amount >= value {
            amount -= value
            return true
        }
        return false
    }
}

// MARK: - Planet Colony
struct PlanetColony: Codable {
    var name: String = "New Terra"
    var population: Int = 25 // Начинаем с небольшой колонии
    var happiness: Double = 0.5 // Средний уровень счастья для начала
    var resources: [GameResource] = []
    var buildings: [Building] = []
    
    init() {
        setupDefaultResources()
        setupDefaultBuildings()
    }
    
    private mutating func setupDefaultResources() {
        resources = [
            GameResource(name: "Energy", amount: 100, maxCapacity: 1000, icon: "bolt.fill", description: "Powers all colony operations"),
            GameResource(name: "Food", amount: 50, maxCapacity: 800, icon: "leaf.fill", description: "Keeps colonists healthy and productive"),
            GameResource(name: "Materials", amount: 30, maxCapacity: 600, icon: "cube.fill", description: "Used for construction and repairs"),
            GameResource(name: "Research", amount: 0, maxCapacity: 400, icon: "brain.head.profile", description: "Unlocks new technologies")
        ]
    }
    
    private mutating func setupDefaultBuildings() {
        buildings = [
            Building(name: "Command Center", level: 1, type: .administrative, isBuilt: true), // Основное здание всегда построено
            Building(name: "Solar Array", level: 0, type: .energy, isBuilt: false), // Начинаем без энергетики
            Building(name: "Hydroponic Farm", level: 0, type: .food, isBuilt: false),
            Building(name: "Mining Facility", level: 0, type: .materials, isBuilt: false),
            Building(name: "Research Lab", level: 0, type: .research, isBuilt: false)
        ]
    }
    
    mutating func updateHappiness() {
        let resourceSatisfaction = resources.map { $0.percentage }.reduce(0, +) / Double(resources.count)
        happiness = min(1.0, max(0.0, resourceSatisfaction))
    }
}

// MARK: - Building
struct Building: Identifiable, Codable {
    let id = UUID()
    var name: String
    var level: Int
    var type: BuildingType
    var isBuilt: Bool
    var constructionCost: [String: Int] = [:]
    var productionRate: Int = 10
    
    enum BuildingType: String, Codable, CaseIterable {
        case administrative = "Administrative"
        case energy = "Energy"
        case food = "Food"
        case materials = "Materials"
        case research = "Research"
        
        var icon: String {
            switch self {
            case .administrative: return "building.2.fill"
            case .energy: return "bolt.fill"
            case .food: return "leaf.fill"
            case .materials: return "cube.fill"
            case .research: return "brain.head.profile"
            }
        }
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Cadet"
    case intermediate = "Officer"
    case advanced = "Commander"
    case expert = "Admiral"
    
    var multiplier: Double {
        switch self {
        case .beginner: return 1.0
        case .intermediate: return 1.5
        case .advanced: return 2.0
        case .expert: return 2.5
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Perfect for space cadets new to financial planning"
        case .intermediate: return "For officers ready to tackle complex scenarios"
        case .advanced: return "Challenging missions for experienced commanders"
        case .expert: return "Elite-level financial strategy for admirals"
        }
    }
}
