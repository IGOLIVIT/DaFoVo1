//
//  OnboardingView.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Onboarding Flow
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var selectedDifficulty: DifficultyLevel = .beginner
    @State private var playerName = ""
    @State private var selectedColonyName = "New Terra"
    
    let onboardingPages = [
        OnboardingPage(
            title: "Welcome to Galaxy Finance Quest",
            description: "Embark on an epic journey through space while mastering the art of financial planning and resource management.",
            imageName: "star.fill",
            backgroundColor: Color.galaxyBackground
        ),
        OnboardingPage(
            title: "Build Your Space Colony",
            description: "Manage resources, construct buildings, and grow your colony while learning essential financial skills.",
            imageName: "building.2.fill",
            backgroundColor: Color.galaxySecondary
        ),
        OnboardingPage(
            title: "Complete Financial Missions",
            description: "Take on challenging missions that teach real-world financial concepts through engaging gameplay.",
            imageName: "chart.line.uptrend.xyaxis",
            backgroundColor: Color.galaxyAccent.opacity(0.8)
        )
    ]
    
    var body: some View {
        ZStack {
            Color.galaxyBackground
                .ignoresSafeArea()
            
            if currentPage < onboardingPages.count {
                onboardingPageView
            } else {
                setupView
            }
        }
    }
    
    private var onboardingPageView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Page Content
            VStack(spacing: 30) {
                Image(systemName: onboardingPages[currentPage].imageName)
                    .font(.system(size: 80))
                    .foregroundColor(.galaxyAccent)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.6), value: currentPage)
                
                VStack(spacing: 16) {
                    Text(onboardingPages[currentPage].title)
                        .font(GalaxyTheme.titleFont)
                        .foregroundColor(.galaxyText)
                        .multilineTextAlignment(.center)
                    
                    Text(onboardingPages[currentPage].description)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            // Page Indicators
            HStack(spacing: 12) {
                ForEach(0..<onboardingPages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.galaxyAccent : Color.galaxyTextSecondary.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, 40)
            
            // Navigation Buttons
            HStack {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }
                    .font(GalaxyTheme.bodyFont)
                    .foregroundColor(.galaxyTextSecondary)
                }
                
                Spacer()
                
                Button(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
                .font(GalaxyTheme.headlineFont)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                        .fill(Color.galaxyAccent)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
    
    private var setupView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.galaxyAccent)
                    
                    Text("Customize Your Journey")
                        .font(GalaxyTheme.titleFont)
                        .foregroundColor(.galaxyText)
                    
                    Text("Set up your space commander profile")
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyTextSecondary)
                }
                .padding(.top, 40)
                
                // Player Name
                VStack(alignment: .leading, spacing: 12) {
                    Text("Commander Name")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                    
                    TextField("Enter your name", text: $playerName)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyText)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                                .fill(Color.galaxyCard)
                        )
                }
                .padding(.horizontal, 32)
                
                // Colony Name
                VStack(alignment: .leading, spacing: 12) {
                    Text("Colony Name")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                    
                    TextField("Enter colony name", text: $selectedColonyName)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyText)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                                .fill(Color.galaxyCard)
                        )
                }
                .padding(.horizontal, 32)
                
                // Difficulty Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose Your Difficulty")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 12) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            DifficultyCard(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                // Start Button
                Button("Begin Your Quest") {
                    completeOnboarding()
                }
                .font(GalaxyTheme.headlineFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                        .fill(Color.galaxyAccent)
                )
                .padding(.horizontal, 32)
                .padding(.top, 20)
                .disabled(playerName.isEmpty)
                .opacity(playerName.isEmpty ? 0.6 : 1.0)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(playerName, forKey: "playerName")
        UserDefaults.standard.set(selectedColonyName, forKey: "colonyName")
        UserDefaults.standard.set(selectedDifficulty.rawValue, forKey: "selectedDifficulty")
        
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

struct DifficultyCard: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(difficulty.rawValue)
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                    
                    Text(difficulty.description)
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyTextSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
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

#Preview {
    OnboardingView()
}

