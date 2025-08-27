//
//  GameViewModel.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Game Logic
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var userProgress: UserProgress
    @Published var planetColony: PlanetColony
    @Published var availableMissions: [Mission] = []
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    @Published var showingMissionDetail = false
    @Published var selectedMission: Mission?
    
    private let dataLoader = DataLoader.shared
    private var gameTimer: Timer?
    
    init() {
        self.userProgress = UserProgress()
        self.planetColony = PlanetColony()
        loadGameData()
        startGameTimer()
    }
    
    // MARK: - Game Data Management
    func loadGameData() {
        isLoading = true
        dataLoader.loadProgress()
        userProgress = dataLoader.userProgress
        availableMissions = dataLoader.loadMissions()
        achievements = dataLoader.loadAchievements()
        updateMissionAvailability()
        isLoading = false
    }
    
    func saveGameData() {
        dataLoader.userProgress = userProgress
        dataLoader.saveProgress()
    }
    
    // MARK: - Mission Management
    func updateMissionAvailability() {
        for i in 0..<availableMissions.count {
            let mission = availableMissions[i]
            let prerequisitesMet = mission.prerequisites.allSatisfy { prerequisite in
                userProgress.completedMissions.contains(prerequisite)
            }
            availableMissions[i].isLocked = !prerequisitesMet
        }
    }
    
    func startMission(_ mission: Mission) {
        selectedMission = mission
        showingMissionDetail = true
    }
    
    func completeMission(_ mission: Mission, score: Double) {
        userProgress.completeMission(mission.id)
        
        let baseRewards = mission.adjustedRewards
        let bonusRewards = Int(Double(baseRewards) * score)
        let totalRewards = baseRewards + bonusRewards
        
        userProgress.addCredits(totalRewards)
        userProgress.addExperience(mission.difficulty == .beginner ? 50 : mission.difficulty == .intermediate ? 100 : 200)
        
        // Update mission completion
        if let index = availableMissions.firstIndex(where: { $0.id == mission.id }) {
            availableMissions[index].isCompleted = true
        }
        
        checkAchievements()
        updateMissionAvailability()
        saveGameData()
        
        // Update colony resources based on mission type
        updateColonyFromMission(mission)
    }
    
    private func updateColonyFromMission(_ mission: Mission) {
        let baseBonus = Int(Double(mission.adjustedRewards) * 0.1)
        
        switch mission.challengeType {
        case .budgeting:
            // Budgeting missions improve energy efficiency
            planetColony.resources[0].add(baseBonus + 30) // Energy
            planetColony.population += 5
            
        case .investing:
            // Investment missions generate more credits and research
            userProgress.addCredits(baseBonus + 50)
            planetColony.resources[3].add(baseBonus + 15) // Research
            
        case .saving:
            // Saving missions improve food storage and population growth
            planetColony.resources[1].add(baseBonus + 25) // Food
            planetColony.population += 10
            
        case .debtManagement:
            // Debt management improves material efficiency
            planetColony.resources[2].add(baseBonus + 35) // Materials
            userProgress.addCredits(baseBonus + 25) // Save money from better debt management
            
        case .riskManagement:
            // Risk management provides balanced growth and emergency reserves
            planetColony.resources[3].add(baseBonus + 20) // Research
            for index in planetColony.resources.indices {
                planetColony.resources[index].add(5) // Small boost to all resources
            }
            
        case .emergencyPlanning:
            // Emergency planning boosts all resources and happiness
            for index in planetColony.resources.indices {
                planetColony.resources[index].add(baseBonus + 15)
            }
            planetColony.population += 3
        }
        
        // Update happiness based on resource levels and population growth
        planetColony.updateHappiness()
        
        // Trigger notifications for significant changes
        if planetColony.population > 200 {
            NotificationService.shared.scheduleResourceLowNotification()
        }
    }
    
    // MARK: - Achievement System
    func checkAchievements() {
        // First mission achievement
        if userProgress.completedMissions.count == 1 && !userProgress.unlockedAchievements.contains("first_mission") {
            unlockAchievement("first_mission")
            userProgress.addCredits(100) // Bonus for first achievement
        }
        
        // Budget master achievement
        let budgetMissions = availableMissions.filter { $0.challengeType == .budgeting && userProgress.completedMissions.contains($0.id) }
        if budgetMissions.count >= 2 && !userProgress.unlockedAchievements.contains("budget_master") {
            unlockAchievement("budget_master")
            planetColony.resources[0].add(100) // Energy bonus
        }
        
        // Investment guru achievement
        let investmentMissions = availableMissions.filter { $0.challengeType == .investing && userProgress.completedMissions.contains($0.id) }
        if investmentMissions.count >= 2 && !userProgress.unlockedAchievements.contains("investment_guru") {
            unlockAchievement("investment_guru")
            userProgress.addCredits(500) // Investment bonus
        }
        
        // Risk expert achievement
        let riskMissions = availableMissions.filter { $0.challengeType == .riskManagement && userProgress.completedMissions.contains($0.id) }
        if riskMissions.count >= 1 && !userProgress.unlockedAchievements.contains("risk_expert") {
            unlockAchievement("risk_expert")
            // Boost all resources as risk management reward
            for index in planetColony.resources.indices {
                planetColony.resources[index].add(50)
            }
        }
        
        // Wealth builder achievement
        if userProgress.credits >= 5000 && !userProgress.unlockedAchievements.contains("wealth_builder") {
            unlockAchievement("wealth_builder")
            planetColony.population += 50 // Population boost for wealth
        }
        
        // Colony growth achievements
        if planetColony.population >= 500 && !userProgress.unlockedAchievements.contains("colony_growth") {
            unlockAchievement("colony_growth")
        }
        
        // Happiness achievement
        if planetColony.happiness >= 0.9 && !userProgress.unlockedAchievements.contains("happy_colony") {
            unlockAchievement("happy_colony")
            userProgress.addCredits(300)
        }
        
        // Level achievements
        if userProgress.level >= 5 && !userProgress.unlockedAchievements.contains("experienced_commander") {
            unlockAchievement("experienced_commander")
        }
        
        if userProgress.level >= 10 && !userProgress.unlockedAchievements.contains("veteran_commander") {
            unlockAchievement("veteran_commander")
        }
    }
    
    private func unlockAchievement(_ achievementId: String) {
        userProgress.unlockAchievement(achievementId)
        if let index = achievements.firstIndex(where: { $0.id == achievementId }) {
            achievements[index].unlock()
        }
    }
    
    // MARK: - Colony Management
    func upgradeBuilding(_ building: Building) -> Bool {
        let upgradeCost = building.level * 100
        if userProgress.credits >= upgradeCost {
            userProgress.addCredits(-upgradeCost)
            
            if let index = planetColony.buildings.firstIndex(where: { $0.id == building.id }) {
                planetColony.buildings[index].level += 1
                planetColony.buildings[index].productionRate += 5
            }
            
            saveGameData()
            return true
        }
        return false
    }
    
    func constructBuilding(_ building: Building) -> Bool {
        let constructionCost = building.level == 0 ? 200 : 500 // Первая постройка дешевле
        if userProgress.credits >= constructionCost && !building.isBuilt {
            userProgress.addCredits(-constructionCost)
            
            if let index = planetColony.buildings.firstIndex(where: { $0.id == building.id }) {
                planetColony.buildings[index].isBuilt = true
                // Если здание было на уровне 0, поднимаем до 1
                if planetColony.buildings[index].level == 0 {
                    planetColony.buildings[index].level = 1
                }
            }
            
            saveGameData()
            return true
        }
        return false
    }
    
    // MARK: - Game Timer
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.updateColonyResources()
        }
    }
    
    private func updateColonyResources() {
        for building in planetColony.buildings where building.isBuilt {
            switch building.type {
            case .energy:
                planetColony.resources[0].add(building.productionRate)
            case .food:
                planetColony.resources[1].add(building.productionRate)
            case .materials:
                planetColony.resources[2].add(building.productionRate)
            case .research:
                planetColony.resources[3].add(building.productionRate)
            case .administrative:
                // Administrative buildings boost all production
                for index in planetColony.resources.indices {
                    planetColony.resources[index].add(2)
                }
            }
        }
        
        planetColony.updateHappiness()
        objectWillChange.send()
    }
    
    // MARK: - Difficulty Management
    func changeDifficulty(_ newDifficulty: DifficultyLevel) {
        userProgress.currentDifficulty = newDifficulty
        saveGameData()
    }
    
    // MARK: - Reset Game
    func resetGame() {
        gameTimer?.invalidate()
        
        // Clear all data in DataLoader first
        dataLoader.clearProgress()
        
        // Reset local state
        userProgress = UserProgress()
        planetColony = PlanetColony()
        availableMissions = dataLoader.loadMissions()
        achievements = dataLoader.loadAchievements()
        selectedMission = nil
        showingMissionDetail = false
        updateMissionAvailability()
        startGameTimer()
    }
    
    // MARK: - Cleanup
    deinit {
        gameTimer?.invalidate()
    }
}
