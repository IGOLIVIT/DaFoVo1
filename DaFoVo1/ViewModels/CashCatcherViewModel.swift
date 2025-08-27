//
//  CashCatcherViewModel.swift
//  DaFoVo1
//
//  Cash Catcher Mini-Game Logic
//

import Foundation
import SwiftUI
import Combine

class CashCatcherViewModel: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var stats: GameStats = GameStats()
    @Published var fallingBills: [FallingBill] = []
    @Published var stars: [Star] = []
    @Published var gameTime: TimeInterval = 0
    
    private var gameTimer: Timer?
    private var billSpawnTimer: Timer?
    private var gameUpdateTimer: Timer?
    private let gameArea: CGRect
    
    // Game settings
    private let gameDuration: TimeInterval = 60 // 60 seconds game
    private let billSpawnInterval: TimeInterval = 1.5 // Spawn bill every 1.5 seconds
    private let gameUpdateInterval: TimeInterval = 1.0/60.0 // 60 FPS
    
    init(gameArea: CGRect = CGRect(x: 0, y: 0, width: 400, height: 800)) {
        self.gameArea = gameArea
        loadHighScore()
        generateStars()
    }
    
    // MARK: - Game Control
    func startGame() {
        resetGame()
        gameState = .playing
        
        // Start timers
        startGameTimer()
        startBillSpawnTimer()
        startGameUpdateTimer()
    }
    
    func pauseGame() {
        gameState = .paused
        stopTimers()
    }
    
    func resumeGame() {
        gameState = .playing
        startGameTimer()
        startBillSpawnTimer()
        startGameUpdateTimer()
    }
    
    func endGame() {
        gameState = .gameOver
        stopTimers()
        
        // Update high score
        if stats.score > stats.highScore {
            stats.highScore = stats.score
            saveHighScore()
        }
    }
    
    func resetGame() {
        stats = GameStats(highScore: stats.highScore)
        fallingBills.removeAll()
        gameTime = 0
    }
    
    func returnToMenu() {
        gameState = .menu
        stopTimers()
        resetGame()
    }
    
    // MARK: - Game Logic
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.gameTime += 1
            self.stats.gameTime = self.gameTime
            
            if self.gameTime >= self.gameDuration {
                self.endGame()
            }
        }
    }
    
    private func startBillSpawnTimer() {
        billSpawnTimer = Timer.scheduledTimer(withTimeInterval: billSpawnInterval, repeats: true) { _ in
            self.spawnBill()
        }
    }
    
    private func startGameUpdateTimer() {
        gameUpdateTimer = Timer.scheduledTimer(withTimeInterval: gameUpdateInterval, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    private func stopTimers() {
        gameTimer?.invalidate()
        billSpawnTimer?.invalidate()
        gameUpdateTimer?.invalidate()
        gameTimer = nil
        billSpawnTimer = nil
        gameUpdateTimer = nil
    }
    
    private func spawnBill() {
        guard gameState == .playing else { return }
        
        let denomination = selectRandomDenomination()
        let xPosition = CGFloat.random(in: 50...(gameArea.width - 50))
        let startPosition = CGPoint(x: xPosition, y: -50)
        
        let bill = FallingBill(position: startPosition, denomination: denomination)
        fallingBills.append(bill)
    }
    
    private func selectRandomDenomination() -> BillDenomination {
        let random = Double.random(in: 0...1)
        var cumulativeProbability: Double = 0
        
        for denomination in BillDenomination.allCases {
            cumulativeProbability += denomination.spawnProbability
            if random <= cumulativeProbability {
                return denomination
            }
        }
        
        return .one // Fallback
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Update bill positions
        for i in fallingBills.indices.reversed() {
            fallingBills[i].position.y += fallingBills[i].velocity * CGFloat(gameUpdateInterval)
            
            // Remove bills that have fallen off screen
            if fallingBills[i].position.y > gameArea.height + 50 {
                stats.billsMissed += 1
                fallingBills.remove(at: i)
            }
        }
    }
    
    // MARK: - User Interaction
    func catchBill(at position: CGPoint) {
        guard gameState == .playing else { return }
        
        for i in fallingBills.indices.reversed() {
            let bill = fallingBills[i]
            let billRect = CGRect(
                x: bill.position.x - 30,
                y: bill.position.y - 15,
                width: 60,
                height: 30
            )
            
            if billRect.contains(position) {
                // Bill caught!
                stats.score += bill.denomination.rawValue
                stats.billsCaught += 1
                fallingBills.remove(at: i)
                
                // Add visual feedback here if needed
                break // Only catch one bill per tap
            }
        }
    }
    
    // MARK: - Background Stars
    func generateStars() {
        stars = (0..<100).map { _ in
            Star(in: gameArea)
        }
    }
    
    // MARK: - Persistence
    private func loadHighScore() {
        stats.highScore = UserDefaults.standard.integer(forKey: "CashCatcherHighScore")
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(stats.highScore, forKey: "CashCatcherHighScore")
    }
    
    // MARK: - Computed Properties
    var remainingTime: TimeInterval {
        return max(0, gameDuration - gameTime)
    }
    
    var formattedTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedScore: String {
        return "$\(stats.score)"
    }
    
    var accuracyPercentage: String {
        return String(format: "%.1f%%", stats.accuracy * 100)
    }
}
