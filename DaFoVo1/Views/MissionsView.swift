//
//  MissionsView.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Missions Interface
//

import SwiftUI

struct MissionsView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var selectedCategory: Mission.ChallengeType? = nil
    
    var filteredMissions: [Mission] {
        if let category = selectedCategory {
            return gameViewModel.availableMissions.filter { $0.challengeType == category }
        }
        return gameViewModel.availableMissions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(
                        title: "All",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(Mission.ChallengeType.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            
            // Missions List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredMissions, id: \.id) { mission in
                        MissionCard(mission: mission, gameViewModel: gameViewModel)
                    }
                }
                .padding()
            }
        }
        .background(Color.galaxyBackground)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GalaxyTheme.captionFont)
                .foregroundColor(isSelected ? .white : .galaxyTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.galaxyAccent : Color.galaxyCard)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MissionCard: View {
    let mission: Mission
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            if mission.isAvailable {
                showingDetail = true
            }
        } label: {
            HStack(spacing: 16) {
                // Mission Icon
                VStack {
                    Image(systemName: mission.challengeType.icon)
                        .font(.title)
                        .foregroundColor(mission.isCompleted ? .galaxySuccess : mission.isAvailable ? .galaxyAccent : .galaxyTextSecondary)
                    
                    if mission.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.galaxySuccess)
                    } else if mission.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.galaxyTextSecondary)
                    }
                }
                .frame(width: 60)
                
                // Mission Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(mission.title)
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyText)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(mission.difficulty.rawValue)
                            .font(GalaxyTheme.captionFont)
                            .foregroundColor(.galaxyTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.galaxySecondary.opacity(0.3))
                            )
                    }
                    
                    Text(mission.description)
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyTextSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.galaxyAccent)
                                .font(.caption)
                            Text("\(mission.adjustedRewards)")
                                .font(GalaxyTheme.captionFont)
                                .foregroundColor(.galaxyText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.galaxyTextSecondary)
                                .font(.caption)
                            Text(mission.estimatedDuration)
                                .font(GalaxyTheme.captionFont)
                                .foregroundColor(.galaxyTextSecondary)
                        }
                    }
                }
                
                // Arrow
                if mission.isAvailable {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.galaxyTextSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                    .fill(mission.isCompleted ? Color.galaxySuccess.opacity(0.1) : Color.galaxyCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .stroke(mission.isCompleted ? Color.galaxySuccess : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!mission.isAvailable)
        .opacity(mission.isLocked ? 0.6 : 1.0)
        .sheet(isPresented: $showingDetail) {
            MissionDetailView(mission: mission, gameViewModel: gameViewModel)
        }
    }
}

struct MissionDetailView: View {
    let mission: Mission
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingChallenge = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: mission.challengeType.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.galaxyAccent)
                        
                        Text(mission.title)
                            .font(GalaxyTheme.titleFont)
                            .foregroundColor(.galaxyText)
                            .multilineTextAlignment(.center)
                        
                        Text(mission.description)
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Mission Stats
                    HStack(spacing: 20) {
                        StatCard(
                            icon: "star.fill",
                            title: "Difficulty",
                            value: mission.difficulty.rawValue,
                            color: .galaxyAccent
                        )
                        
                        StatCard(
                            icon: "dollarsign.circle.fill",
                            title: "Rewards",
                            value: "\(mission.adjustedRewards)",
                            color: .galaxySuccess
                        )
                        
                        StatCard(
                            icon: "clock.fill",
                            title: "Duration",
                            value: mission.estimatedDuration,
                            color: .galaxyWarning
                        )
                    }
                    
                    // Educational Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What You'll Learn")
                            .font(GalaxyTheme.headlineFont)
                            .foregroundColor(.galaxyText)
                        
                        Text(mission.educationalContent)
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyTextSecondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyCard)
                    )
                    
                    // Start Button
                    Button("Start Mission") {
                        gameViewModel.startMission(mission)
                        showingChallenge = true
                    }
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(mission.isCompleted ? Color.galaxyTextSecondary : Color.galaxyAccent)
                    )
                    .disabled(mission.isCompleted)
                    
                    if mission.isCompleted {
                        Text("Mission Completed!")
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxySuccess)
                    }
                }
                .padding()
            }
            .background(Color.galaxyBackground)
            .navigationTitle("Mission Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
        .fullScreenCover(isPresented: $showingChallenge) {
            if let selectedMission = gameViewModel.selectedMission {
                FinanceChallengeView(mission: selectedMission, gameViewModel: gameViewModel)
            } else {
                // Fallback view if no mission is selected
                VStack {
                    Text("No mission selected")
                        .foregroundColor(.galaxyText)
                    Button("Close") {
                        showingChallenge = false
                    }
                    .foregroundColor(.galaxyAccent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.galaxyBackground)
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(GalaxyTheme.captionFont)
                .foregroundColor(.galaxyTextSecondary)
            
            Text(value)
                .font(GalaxyTheme.bodyFont)
                .foregroundColor(.galaxyText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.galaxyCard)
        )
    }
}

#Preview {
    MissionsView(gameViewModel: GameViewModel())
}
