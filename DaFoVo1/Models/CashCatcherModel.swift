//
//  CashCatcherModel.swift
//  DaFoVo1
//
//  Cash Catcher Mini-Game Models
//

import Foundation
import SwiftUI

// MARK: - Falling Bill Model
struct FallingBill: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGFloat
    let denomination: BillDenomination
    let rotation: Double
    let rotationSpeed: Double
    
    init(position: CGPoint, denomination: BillDenomination) {
        self.position = position
        self.velocity = CGFloat.random(in: 50...120) // Pixels per second
        self.denomination = denomination
        self.rotation = Double.random(in: 0...360)
        self.rotationSpeed = Double.random(in: -180...180) // Degrees per second
    }
}

// MARK: - Bill Denominations
enum BillDenomination: Int, CaseIterable {
    case one = 1
    case five = 5
    case ten = 10
    case twenty = 20
    case fifty = 50
    case hundred = 100
    
    var color: Color {
        switch self {
        case .one:
            return Color.green.opacity(0.8)
        case .five:
            return Color.purple.opacity(0.8)
        case .ten:
            return Color.orange.opacity(0.8)
        case .twenty:
            return Color.blue.opacity(0.8)
        case .fifty:
            return Color.red.opacity(0.8)
        case .hundred:
            return Color.yellow.opacity(0.8)
        }
    }
    
    var displayText: String {
        return "$\(rawValue)"
    }
    
    var spawnProbability: Double {
        switch self {
        case .one:
            return 0.35 // 35% chance
        case .five:
            return 0.25 // 25% chance
        case .ten:
            return 0.20 // 20% chance
        case .twenty:
            return 0.12 // 12% chance
        case .fifty:
            return 0.06 // 6% chance
        case .hundred:
            return 0.02 // 2% chance
        }
    }
}

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

// MARK: - Game Statistics
struct GameStats {
    var score: Int = 0
    var billsCaught: Int = 0
    var billsMissed: Int = 0
    var gameTime: TimeInterval = 0
    var highScore: Int = 0
    
    var accuracy: Double {
        let total = billsCaught + billsMissed
        return total > 0 ? Double(billsCaught) / Double(total) : 0.0
    }
}

// MARK: - Star for Background
struct Star: Identifiable {
    let id = UUID()
    let position: CGPoint
    let brightness: Double
    let size: CGFloat
    
    init(in bounds: CGRect) {
        self.position = CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height)
        )
        self.brightness = Double.random(in: 0.3...1.0)
        self.size = CGFloat.random(in: 1...3)
    }
}
