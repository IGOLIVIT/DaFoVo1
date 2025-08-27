//
//  FinanceChallengeView.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Challenge Interface
//

import SwiftUI

struct FinanceChallengeView: View {
    let mission: Mission
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var challengeViewModel = FinanceChallengeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.galaxyBackground
                .ignoresSafeArea()
            
            if challengeViewModel.showingResults {
                resultsView
            } else {
                challengeView
            }
        }
        .onAppear {
            challengeViewModel.startChallenge(for: mission)
        }
    }
    
    private var challengeView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Question Content
            if challengeViewModel.currentQuestionIndex < challengeViewModel.currentQuestions.count && !challengeViewModel.currentQuestions.isEmpty {
                questionView
            } else {
                Text("Loading question...")
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.galaxyText)
                    .padding()
            }
            
            Spacer()
            
            // Answer Buttons or Explanation
            if challengeViewModel.showingExplanation {
                explanationView
            } else {
                answerButtonsView
            }
        }
        .padding()
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Progress and Timer
            HStack {
                Button("Exit") {
                    dismiss()
                }
                .font(GalaxyTheme.captionFont)
                .foregroundColor(.galaxyTextSecondary)
                
                Spacer()
                
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.galaxyWarning)
                    Text(timeString(from: challengeViewModel.timeRemaining))
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.galaxyCard)
                )
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(challengeViewModel.currentQuestionIndex + 1) of \(challengeViewModel.totalQuestions)")
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyTextSecondary)
                    
                    Spacer()
                    
                    Text("Score: \(challengeViewModel.score)")
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyText)
                }
                
                ProgressView(value: Double(challengeViewModel.currentQuestionIndex + 1), total: Double(challengeViewModel.totalQuestions))
                    .progressViewStyle(LinearProgressViewStyle(tint: .galaxyAccent))
                    .frame(height: 8)
            }
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 24) {
            // Question
            Text(challengeViewModel.currentQuestions[challengeViewModel.currentQuestionIndex].question)
                .font(GalaxyTheme.headlineFont)
                .foregroundColor(.galaxyText)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                        .fill(Color.galaxyCard)
                )
        }
        .padding(.top, 32)
    }
    
    private var answerButtonsView: some View {
        VStack(spacing: 16) {
            if challengeViewModel.currentQuestionIndex < challengeViewModel.currentQuestions.count && !challengeViewModel.currentQuestions.isEmpty {
                ForEach(Array(challengeViewModel.currentQuestions[challengeViewModel.currentQuestionIndex].answers.enumerated()), id: \.offset) { index, answer in
                    AnswerButton(
                        text: answer,
                        isSelected: challengeViewModel.selectedAnswerIndex == index,
                        action: {
                            challengeViewModel.selectAnswer(index)
                        }
                    )
                }
            }
            
            // Submit Button
            Button("Submit Answer") {
                challengeViewModel.submitAnswer()
            }
            .font(GalaxyTheme.bodyFont)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                    .fill(challengeViewModel.selectedAnswerIndex != nil ? Color.galaxyAccent : Color.galaxyTextSecondary)
            )
            .disabled(challengeViewModel.selectedAnswerIndex == nil)
            .padding(.top, 16)
        }
    }
    
    private var explanationView: some View {
        VStack(spacing: 20) {
            if challengeViewModel.currentQuestionIndex < challengeViewModel.currentQuestions.count && !challengeViewModel.currentQuestions.isEmpty {
                // Correct/Incorrect Indicator
                HStack {
                    let isCorrect = challengeViewModel.currentQuestions[challengeViewModel.currentQuestionIndex].isCorrect(challengeViewModel.selectedAnswerIndex ?? -1)
                    
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(isCorrect ? .galaxySuccess : .galaxyAccent)
                    
                    Text(isCorrect ? "Correct!" : "Incorrect")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(isCorrect ? .galaxySuccess : .galaxyAccent)
                }
                
                // Explanation
                Text(challengeViewModel.currentQuestions[challengeViewModel.currentQuestionIndex].explanation)
                    .font(GalaxyTheme.bodyFont)
                    .foregroundColor(.galaxyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyCard)
                    )
            }
            
            // Next Button
            Button(challengeViewModel.currentQuestionIndex < challengeViewModel.totalQuestions - 1 ? "Next Question" : "Complete Challenge") {
                challengeViewModel.nextQuestion()
            }
            .font(GalaxyTheme.bodyFont)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                    .fill(Color.galaxyAccent)
            )
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Results Header
            VStack(spacing: 16) {
                Image(systemName: challengeViewModel.isMissionFailed() ? "xmark.circle.fill" : "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(challengeViewModel.isMissionFailed() ? .galaxyAccent : .galaxySuccess)
                
                Text(challengeViewModel.isMissionFailed() ? "Mission Failed!" : "Mission Complete!")
                    .font(GalaxyTheme.titleFont)
                    .foregroundColor(.galaxyText)
                
                Text(challengeViewModel.getPerformanceRating())
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.galaxyTextSecondary)
            }
            
            // Score Summary
            VStack(spacing: 16) {
                ScoreCard(
                    title: "Final Score",
                    value: "\(challengeViewModel.score)",
                    icon: "star.fill",
                    color: .galaxyAccent
                )
                
                ScoreCard(
                    title: "Accuracy",
                    value: "\(Int(challengeViewModel.getScorePercentage() * 100))%",
                    icon: "target",
                    color: .galaxySuccess
                )
                
                ScoreCard(
                    title: "Credits Earned",
                    value: challengeViewModel.isMissionFailed() ? "0" : "\(mission.adjustedRewards + Int(Double(mission.adjustedRewards) * challengeViewModel.getScorePercentage()))",
                    icon: "dollarsign.circle.fill",
                    color: challengeViewModel.isMissionFailed() ? .galaxyTextSecondary : .galaxyWarning
                )
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                if challengeViewModel.isMissionFailed() {
                    // Mission Failed - Show Try Again button
                    Button("Try Again") {
                        challengeViewModel.resetChallenge()
                    }
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyWarning)
                    )
                    
                    Button("Back to Missions") {
                        dismiss()
                    }
                    .font(GalaxyTheme.bodyFont)
                    .foregroundColor(.galaxyTextSecondary)
                } else {
                    // Mission Passed - Show Collect Rewards button
                    Button("Collect Rewards") {
                        gameViewModel.completeMission(mission, score: challengeViewModel.getScorePercentage())
                        dismiss()
                    }
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyAccent)
                    )
                    
                    Button("Try Again for Better Score") {
                        challengeViewModel.resetChallenge()
                    }
                    .font(GalaxyTheme.bodyFont)
                    .foregroundColor(.galaxyTextSecondary)
                }
            }
        }
        .padding()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(GalaxyTheme.bodyFont)
                    .foregroundColor(.galaxyText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.galaxyAccent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                    .fill(isSelected ? Color.galaxyAccent.opacity(0.1) : Color.galaxyCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .stroke(isSelected ? Color.galaxyAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ScoreCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GalaxyTheme.captionFont)
                    .foregroundColor(.galaxyTextSecondary)
                
                Text(value)
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.galaxyText)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                .fill(Color.galaxyCard)
        )
    }
}

#Preview {
    FinanceChallengeView(
        mission: Mission(
            id: "test",
            title: "Test Mission",
            description: "A test mission",
            difficulty: .beginner,
            rewards: 100,
            educationalContent: "Test content",
            challengeType: .budgeting,
            isCompleted: false
        ),
        gameViewModel: GameViewModel()
    )
}
