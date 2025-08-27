//
//  FinanceChallengeViewModel.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Challenge Logic
//

import Foundation
import SwiftUI

class FinanceChallengeViewModel: ObservableObject {
    @Published var currentMission: Mission?
    @Published var currentQuestions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var showingExplanation = false
    @Published var score = 0
    @Published var totalQuestions = 0
    @Published var isCompleted = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var showingResults = false
    
    private var challengeTimer: Timer?
    private var startTime: Date?
    
    // MARK: - Challenge Management
    func startChallenge(for mission: Mission) {
        currentMission = mission
        currentQuestions = generateQuestions(for: mission)
        
        // Ensure we have questions
        if currentQuestions.isEmpty {
            currentQuestions = [
                QuizQuestion(
                    question: "This is a sample question for \(mission.title)",
                    answers: ["Option A", "Option B", "Option C", "Option D"],
                    correctAnswerIndex: 0,
                    explanation: "This is a sample explanation.",
                    category: mission.challengeType,
                    difficulty: mission.difficulty,
                    points: 10
                )
            ]
        }
        
        totalQuestions = currentQuestions.count
        currentQuestionIndex = 0
        score = 0
        selectedAnswerIndex = nil
        showingExplanation = false
        isCompleted = false
        showingResults = false
        startTime = Date()
        
        // Set time limit based on difficulty
        switch mission.difficulty {
        case .beginner:
            timeRemaining = 300 // 5 minutes
        case .intermediate:
            timeRemaining = 600 // 10 minutes
        case .advanced:
            timeRemaining = 900 // 15 minutes
        case .expert:
            timeRemaining = 1200 // 20 minutes
        }
        
        startTimer()
    }
    
    private func startTimer() {
        challengeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeChallenge()
            }
        }
    }
    
    func selectAnswer(_ index: Int) {
        selectedAnswerIndex = index
    }
    
    func submitAnswer() {
        guard let selectedIndex = selectedAnswerIndex,
              currentQuestionIndex < currentQuestions.count else { return }
        
        let currentQuestion = currentQuestions[currentQuestionIndex]
        
        if currentQuestion.isCorrect(selectedIndex) {
            score += currentQuestion.points
        }
        
        showingExplanation = true
    }
    
    func nextQuestion() {
        showingExplanation = false
        selectedAnswerIndex = nil
        
        if currentQuestionIndex < currentQuestions.count - 1 {
            currentQuestionIndex += 1
        } else {
            completeChallenge()
        }
    }
    
    private func completeChallenge() {
        challengeTimer?.invalidate()
        isCompleted = true
        showingResults = true
    }
    
    func getScorePercentage() -> Double {
        let maxPossibleScore = currentQuestions.reduce(0) { $0 + $1.points }
        return maxPossibleScore > 0 ? Double(score) / Double(maxPossibleScore) : 0.0
    }
    
    func getPerformanceRating() -> String {
        let percentage = getScorePercentage()
        switch percentage {
        case 0.9...1.0:
            return "Excellent! 🌟"
        case 0.8..<0.9:
            return "Great Job! 👏"
        case 0.7..<0.8:
            return "Good Work! 👍"
        case 0.6..<0.7:
            return "Not Bad! 🙂"
        default:
            return "Keep Learning! 📚"
        }
    }
    
    func isMissionFailed() -> Bool {
        return getScorePercentage() < 0.6 // Считаем провалом результат менее 60%
    }
    
    func resetChallenge() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswerIndex = nil
        showingExplanation = false
        isCompleted = false
        showingResults = false
        startTime = Date()
        
        // Restart timer
        challengeTimer?.invalidate()
        if let mission = currentMission {
            switch mission.difficulty {
            case .beginner:
                timeRemaining = 300 // 5 minutes
            case .intermediate:
                timeRemaining = 600 // 10 minutes
            case .advanced:
                timeRemaining = 900 // 15 minutes
            case .expert:
                timeRemaining = 1200 // 20 minutes
            }
            startTimer()
        }
    }
    
    // MARK: - Question Generation
    private func generateQuestions(for mission: Mission) -> [QuizQuestion] {
        switch mission.challengeType {
        case .budgeting:
            return generateBudgetingQuestions(difficulty: mission.difficulty)
        case .investing:
            return generateInvestingQuestions(difficulty: mission.difficulty)
        case .saving:
            return generateSavingQuestions(difficulty: mission.difficulty)
        case .debtManagement:
            return generateDebtQuestions(difficulty: mission.difficulty)
        case .riskManagement:
            return generateRiskQuestions(difficulty: mission.difficulty)
        case .emergencyPlanning:
            return generateEmergencyQuestions(difficulty: mission.difficulty)
        }
    }
    
    private func generateBudgetingQuestions(difficulty: DifficultyLevel) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        questions.append(QuizQuestion(
            question: "What percentage of income should typically be allocated to needs in a balanced budget?",
            answers: ["30%", "50%", "70%", "90%"],
            correctAnswerIndex: 1,
            explanation: "The 50/30/20 rule suggests 50% for needs, 30% for wants, and 20% for savings and debt repayment.",
            category: .budgeting,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        questions.append(QuizQuestion(
            question: "Which expense category should be prioritized first when creating a budget?",
            answers: ["Entertainment", "Essential needs", "Luxury items", "Hobbies"],
            correctAnswerIndex: 1,
            explanation: "Essential needs like housing, food, and utilities should always be prioritized first in any budget.",
            category: .budgeting,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        if difficulty != .beginner {
            questions.append(QuizQuestion(
                question: "What is zero-based budgeting?",
                answers: ["Starting with zero income", "Allocating every dollar of income", "Having zero expenses", "Saving zero money"],
                correctAnswerIndex: 1,
                explanation: "Zero-based budgeting means every dollar of income is allocated to specific categories, leaving zero unassigned.",
                category: .budgeting,
                difficulty: difficulty,
                points: 20
            ))
        }
        
        return questions
    }
    
    private func generateInvestingQuestions(difficulty: DifficultyLevel) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        questions.append(QuizQuestion(
            question: "What is compound interest?",
            answers: ["Interest on the principal only", "Interest on principal and accumulated interest", "A type of loan", "A banking fee"],
            correctAnswerIndex: 1,
            explanation: "Compound interest is earned on both the original principal and the accumulated interest from previous periods.",
            category: .investing,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        questions.append(QuizQuestion(
            question: "Which investment strategy reduces risk through variety?",
            answers: ["Concentration", "Diversification", "Speculation", "Day trading"],
            correctAnswerIndex: 1,
            explanation: "Diversification spreads investments across different assets to reduce overall risk.",
            category: .investing,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        if difficulty != .beginner {
            questions.append(QuizQuestion(
                question: "What does P/E ratio measure?",
                answers: ["Price to Earnings", "Profit to Expenses", "Principal to Equity", "Performance to Efficiency"],
                correctAnswerIndex: 0,
                explanation: "P/E ratio (Price-to-Earnings) compares a company's stock price to its earnings per share.",
                category: .investing,
                difficulty: difficulty,
                points: 20
            ))
        }
        
        return questions
    }
    
    private func generateSavingQuestions(difficulty: DifficultyLevel) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        questions.append(QuizQuestion(
            question: "How many months of expenses should an emergency fund cover?",
            answers: ["1-2 months", "3-6 months", "12 months", "24 months"],
            correctAnswerIndex: 1,
            explanation: "Financial experts recommend saving 3-6 months of living expenses for emergencies.",
            category: .saving,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        return questions
    }
    
    private func generateDebtQuestions(difficulty: DifficultyLevel) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        questions.append(QuizQuestion(
            question: "Which debt repayment strategy focuses on highest interest rates first?",
            answers: ["Debt snowball", "Debt avalanche", "Debt consolidation", "Minimum payments"],
            correctAnswerIndex: 1,
            explanation: "The debt avalanche method prioritizes paying off debts with the highest interest rates first to minimize total interest paid.",
            category: .debtManagement,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        return questions
    }
    
    private func generateRiskQuestions(difficulty: DifficultyLevel) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        questions.append(QuizQuestion(
            question: "What is the relationship between risk and potential return in investments?",
            answers: ["No relationship", "Higher risk, lower return", "Higher risk, higher potential return", "Lower risk, higher return"],
            correctAnswerIndex: 2,
            explanation: "Generally, investments with higher risk offer the potential for higher returns, but also greater potential for losses.",
            category: .riskManagement,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        return questions
    }
    
    private func generateEmergencyQuestions(difficulty: DifficultyLevel) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        questions.append(QuizQuestion(
            question: "What should be the first step in emergency financial planning?",
            answers: ["Invest in stocks", "Build an emergency fund", "Buy insurance", "Pay off all debt"],
            correctAnswerIndex: 1,
            explanation: "Building an emergency fund should be the foundation of any emergency financial plan.",
            category: .emergencyPlanning,
            difficulty: difficulty,
            points: difficulty == .beginner ? 10 : 15
        ))
        
        return questions
    }
    
    // MARK: - Cleanup
    deinit {
        challengeTimer?.invalidate()
    }
}
