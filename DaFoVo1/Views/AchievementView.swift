//
//  AchievementView.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Achievements Interface
//

import SwiftUI

struct AchievementView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return gameViewModel.achievements.filter { $0.category == category }
        }
        return gameViewModel.achievements
    }
    
    var unlockedCount: Int {
        gameViewModel.achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        gameViewModel.achievements.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Stats
            headerStatsView
            
            // Category Filter
            categoryFilterView
            
            // Achievements Grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(filteredAchievements, id: \.id) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
        }
        .background(Color.galaxyBackground)
    }
    
    private var headerStatsView: some View {
        VStack(spacing: 16) {
            Text("Achievements")
                .font(GalaxyTheme.titleFont)
                .foregroundColor(.galaxyText)
            
            HStack(spacing: 20) {
                StatBadge(
                    title: "Unlocked",
                    value: "\(unlockedCount)",
                    icon: "trophy.fill",
                    color: .galaxyAccent
                )
                
                StatBadge(
                    title: "Progress",
                    value: "\(Int(Double(unlockedCount) / Double(totalCount) * 100))%",
                    icon: "chart.pie.fill",
                    color: .galaxySuccess
                )
                
                StatBadge(
                    title: "Total",
                    value: "\(totalCount)",
                    icon: "star.fill",
                    color: .galaxyWarning
                )
            }
            
            // Progress Bar
            ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                .progressViewStyle(LinearProgressViewStyle(tint: .galaxyAccent))
                .frame(height: 8)
                .padding(.horizontal, 20)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                .fill(Color.galaxyCard)
        )
        .padding()
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(GalaxyTheme.headlineFont)
                .foregroundColor(.galaxyText)
            
            Text(title)
                .font(GalaxyTheme.captionFont)
                .foregroundColor(.galaxyTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.galaxyBackground)
        )
    }
}

struct CategoryFilterButton: View {
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

struct AchievementCard: View {
    let achievement: Achievement
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            if achievement.isUnlocked {
                showingDetail = true
            }
        } label: {
            VStack(spacing: 12) {
                // Achievement Icon
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? Color.galaxyAccent.opacity(0.2) : Color.galaxyCard)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: achievement.icon)
                        .font(.title)
                        .foregroundColor(achievement.isUnlocked ? .galaxyAccent : .galaxyTextSecondary)
                    
                    if !achievement.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.galaxyTextSecondary)
                            .offset(x: 20, y: -20)
                    }
                }
                
                // Achievement Info
                VStack(spacing: 6) {
                    Text(achievement.title)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(achievement.isUnlocked ? .galaxyText : .galaxyTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(achievement.description)
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Rarity Badge
                if achievement.isUnlocked {
                    Text(achievement.rarity.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(rarityColor(achievement.rarity))
                        )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                    .fill(achievement.isUnlocked ? Color.galaxyCard : Color.galaxyCard.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .stroke(achievement.isUnlocked ? rarityColor(achievement.rarity) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!achievement.isUnlocked)
        .sheet(isPresented: $showingDetail) {
            AchievementDetailView(achievement: achievement)
        }
    }
    
    private func rarityColor(_ rarity: Achievement.AchievementRarity) -> Color {
        switch rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .yellow
        }
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Achievement Icon
                ZStack {
                    Circle()
                        .fill(Color.galaxyAccent.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.galaxyAccent)
                }
                
                // Achievement Info
                VStack(spacing: 16) {
                    Text(achievement.title)
                        .font(GalaxyTheme.titleFont)
                        .foregroundColor(.galaxyText)
                        .multilineTextAlignment(.center)
                    
                    Text(achievement.description)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    // Rarity and Date
                    VStack(spacing: 8) {
                        Text(achievement.rarity.rawValue)
                            .font(GalaxyTheme.headlineFont)
                            .foregroundColor(rarityColor(achievement.rarity))
                        
                        if let unlockedDate = achievement.unlockedDate {
                            Text("Unlocked on \(unlockedDate, style: .date)")
                                .font(GalaxyTheme.captionFont)
                                .foregroundColor(.galaxyTextSecondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyCard)
                    )
                }
                
                Spacer()
                
                // Close Button
                Button("Close") {
                    dismiss()
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
            .padding()
            .background(Color.galaxyBackground)
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func rarityColor(_ rarity: Achievement.AchievementRarity) -> Color {
        switch rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .yellow
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showingSettings = false
    @State private var showingDeleteAlert = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var completionPercentage: Double {
        let totalMissions = gameViewModel.availableMissions.count
        let completedMissions = gameViewModel.userProgress.completedMissions.count
        return totalMissions > 0 ? Double(completedMissions) / Double(totalMissions) : 0.0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.galaxyAccent.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.galaxyAccent)
                        
                        // Level badge
                        Text("\(gameViewModel.userProgress.level)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.galaxyAccent))
                            .offset(x: 35, y: -35)
                    }
                    
                    VStack(spacing: 8) {
                        Text(UserDefaults.standard.string(forKey: "playerName") ?? "Commander")
                            .font(GalaxyTheme.titleFont)
                            .foregroundColor(.galaxyText)
                        
                        Text("\(gameViewModel.userProgress.currentDifficulty.rawValue) • Colony: \(UserDefaults.standard.string(forKey: "colonyName") ?? "New Terra")")
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyTextSecondary)
                        
                        // Progress bar
                        VStack(spacing: 4) {
                            HStack {
                                Text("Mission Progress")
                                    .font(GalaxyTheme.captionFont)
                                    .foregroundColor(.galaxyTextSecondary)
                                Spacer()
                                Text("\(Int(completionPercentage * 100))%")
                                    .font(GalaxyTheme.captionFont)
                                    .foregroundColor(.galaxyText)
                            }
                            
                            ProgressView(value: completionPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: .galaxyAccent))
                                .frame(height: 6)
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Stats Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ProfileStatCard(
                        title: "Credits",
                        value: "\(gameViewModel.userProgress.credits)",
                        icon: "dollarsign.circle.fill",
                        color: .galaxyAccent
                    )
                    
                    ProfileStatCard(
                        title: "Experience",
                        value: "\(gameViewModel.userProgress.experience)",
                        icon: "star.fill",
                        color: .galaxySuccess
                    )
                    
                    ProfileStatCard(
                        title: "Missions",
                        value: "\(gameViewModel.userProgress.completedMissions.count)/\(gameViewModel.availableMissions.count)",
                        icon: "target",
                        color: .galaxyWarning
                    )
                    
                    ProfileStatCard(
                        title: "Achievements",
                        value: "\(gameViewModel.userProgress.unlockedAchievements.count)/\(gameViewModel.achievements.count)",
                        icon: "trophy.fill",
                        color: .purple
                    )
                }
                
                // Colony happiness indicator
                VStack(spacing: 12) {
                    Text("Colony Status")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                    
                    HStack {
                        Image(systemName: "face.smiling.fill")
                            .foregroundColor(gameViewModel.planetColony.happiness > 0.7 ? .galaxySuccess : gameViewModel.planetColony.happiness > 0.4 ? .galaxyWarning : .galaxyAccent)
                        
                        Text("Happiness: \(Int(gameViewModel.planetColony.happiness * 100))%")
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyText)
                        
                        Spacer()
                        
                        Text("Population: \(gameViewModel.planetColony.population)")
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyTextSecondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyCard)
                    )
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Settings") {
                        showingSettings = true
                    }
                    .font(GalaxyTheme.bodyFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                            .fill(Color.galaxyCard)
                    )
                    
                    Button("Delete Account") {
                        showingDeleteAlert = true
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
            .padding()
        }
        .background(Color.galaxyBackground)
        .sheet(isPresented: $showingSettings) {
            SettingsView(gameViewModel: gameViewModel)
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This will permanently delete all your progress, achievements, and colony data. This action cannot be undone.")
        }
    }
    
    private func deleteAccount() {
        // Clear all user data
        UserDefaults.standard.removeObject(forKey: "playerName")
        UserDefaults.standard.removeObject(forKey: "colonyName")
        UserDefaults.standard.removeObject(forKey: "selectedDifficulty")
        UserDefaults.standard.removeObject(forKey: "GalaxyFinanceQuest_UserProgress")
        
        // Reset onboarding
        hasCompletedOnboarding = false
        
        // Reset game state
        gameViewModel.resetGame()
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(GalaxyTheme.headlineFont)
                .foregroundColor(.galaxyText)
            
            Text(title)
                .font(GalaxyTheme.captionFont)
                .foregroundColor(.galaxyTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                .fill(Color.galaxyCard)
        )
    }
}

struct SettingsView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDifficulty: DifficultyLevel
    @State private var playerName: String
    @State private var colonyName: String
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        self._selectedDifficulty = State(initialValue: gameViewModel.userProgress.currentDifficulty)
        self._playerName = State(initialValue: UserDefaults.standard.string(forKey: "playerName") ?? "Commander")
        self._colonyName = State(initialValue: UserDefaults.standard.string(forKey: "colonyName") ?? "New Terra")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Player Name Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Player Settings")
                            .font(GalaxyTheme.headlineFont)
                            .foregroundColor(.galaxyText)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Player Name")
                                .font(GalaxyTheme.bodyFont)
                                .foregroundColor(.galaxyTextSecondary)
                            
                            TextField("Enter your name", text: $playerName)
                                .font(GalaxyTheme.bodyFont)
                                .foregroundColor(.galaxyText)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                                        .fill(Color.galaxyCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                                                .stroke(Color.galaxyAccent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colony Name")
                                .font(GalaxyTheme.bodyFont)
                                .foregroundColor(.galaxyTextSecondary)
                            
                            TextField("Enter colony name", text: $colonyName)
                                .font(GalaxyTheme.bodyFont)
                                .foregroundColor(.galaxyText)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                                        .fill(Color.galaxyCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                                                .stroke(Color.galaxyAccent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    
                    // Difficulty Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Difficulty Level")
                            .font(GalaxyTheme.headlineFont)
                            .foregroundColor(.galaxyText)
                        
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
                    }
                
                    
                    // Save Button
                    Button("Save Changes") {
                        saveSettings()
                        dismiss()
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
                .padding()
            }
            .background(Color.galaxyBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
    
    private func saveSettings() {
        // Save player and colony names
        UserDefaults.standard.set(playerName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "playerName")
        UserDefaults.standard.set(colonyName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "colonyName")
        
        // Save difficulty
        gameViewModel.changeDifficulty(selectedDifficulty)
    }
}

#Preview {
    AchievementView(gameViewModel: GameViewModel())
}
