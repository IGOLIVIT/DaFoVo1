//
//  GameView.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Main Game Interface
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.galaxyBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        ColonyView(gameViewModel: gameViewModel)
                            .tag(0)
                        
                        MissionsView(gameViewModel: gameViewModel)
                            .tag(1)
                        
                        AchievementView(gameViewModel: gameViewModel)
                            .tag(2)
                        
                        CashCatcherView()
                            .tag(3)
                        
                        ProfileView(gameViewModel: gameViewModel)
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom Tab Bar
                    customTabBar
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            gameViewModel.loadGameData()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Galaxy Finance Quest")
                    .font(GalaxyTheme.headlineFont)
                    .foregroundColor(.galaxyText)
                
                Text("Level \(gameViewModel.userProgress.level)")
                    .font(GalaxyTheme.captionFont)
                    .foregroundColor(.galaxyTextSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Credits
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.galaxyAccent)
                    Text("\(gameViewModel.userProgress.credits)")
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.galaxyCard)
                )
                
                // Experience
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.galaxySuccess)
                    Text("\(gameViewModel.userProgress.experience)")
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.galaxyCard)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.galaxyBackground)
    }
    
    private var customTabBar: some View {
        HStack {
            TabBarButton(
                icon: "building.2.fill",
                title: "Colony",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarButton(
                icon: "target",
                title: "Missions",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabBarButton(
                icon: "trophy.fill",
                title: "Achievements",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabBarButton(
                icon: "dollarsign.circle.fill",
                title: "Game",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            TabBarButton(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.galaxyCard)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: -2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .galaxyAccent : .galaxyTextSecondary)
                
                Text(title)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(isSelected ? .galaxyAccent : .galaxyTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Colony View
struct ColonyView: View {
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Colony Header
                VStack(spacing: 12) {
                    Text(gameViewModel.planetColony.name)
                        .font(GalaxyTheme.titleFont)
                        .foregroundColor(.galaxyText)
                    
                    Text("Population: \(gameViewModel.planetColony.population)")
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyTextSecondary)
                    
                    // Happiness Meter
                    HStack {
                        Text("Happiness:")
                            .font(GalaxyTheme.bodyFont)
                            .foregroundColor(.galaxyText)
                        
                        ProgressView(value: gameViewModel.planetColony.happiness)
                            .progressViewStyle(LinearProgressViewStyle(tint: .galaxySuccess))
                            .frame(height: 8)
                        
                        Text("\(Int(gameViewModel.planetColony.happiness * 100))%")
                            .font(GalaxyTheme.captionFont)
                            .foregroundColor(.galaxyTextSecondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                        .fill(Color.galaxyCard)
                )
                
                // Resources
                VStack(alignment: .leading, spacing: 16) {
                    Text("Resources")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(gameViewModel.planetColony.resources, id: \.id) { resource in
                            ResourceCard(resource: resource)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                        .fill(Color.galaxyCard)
                )
                
                // Buildings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Buildings")
                        .font(GalaxyTheme.headlineFont)
                        .foregroundColor(.galaxyText)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(gameViewModel.planetColony.buildings, id: \.id) { building in
                            BuildingCard(building: building, gameViewModel: gameViewModel)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GalaxyTheme.cornerRadius)
                        .fill(Color.galaxyCard)
                )
            }
            .padding()
        }
    }
}

struct ResourceCard: View {
    let resource: GameResource
    
    var statusColor: Color {
        if resource.percentage > 0.8 { return .galaxySuccess }
        else if resource.percentage > 0.5 { return .galaxyWarning }
        else if resource.percentage > 0.2 { return .orange }
        else { return .galaxyAccent }
    }
    
    var statusText: String {
        if resource.percentage > 0.8 { return "Excellent" }
        else if resource.percentage > 0.5 { return "Good" }
        else if resource.percentage > 0.2 { return "Low" }
        else { return "Critical" }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: resource.icon)
                    .foregroundColor(statusColor)
                    .font(.title2)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(resource.amount)/\(resource.maxCapacity)")
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyText)
                    
                    Text(statusText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(statusColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(resource.name)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyText)
                    
                    Spacer()
                    
                    Text("\(Int(resource.percentage * 100))%")
                        .font(GalaxyTheme.captionFont)
                        .foregroundColor(.galaxyTextSecondary)
                }
                
                ProgressView(value: resource.percentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: statusColor))
                    .frame(height: 6)
                
                Text(resource.description)
                    .font(.system(size: 10))
                    .foregroundColor(.galaxyTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.galaxyBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct BuildingCard: View {
    let building: Building
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showingUpgrade = false
    
    var upgradeCost: Int {
        building.level * 100
    }
    
    var canAffordUpgrade: Bool {
        gameViewModel.userProgress.credits >= upgradeCost
    }
    
    var canAffordConstruction: Bool {
        let constructionCost = building.level == 0 ? 200 : 500 // Первая постройка дешевле
        return gameViewModel.userProgress.credits >= constructionCost
    }
    
    var constructionCost: Int {
        return building.level == 0 ? 200 : 500 // Первая постройка дешевле
    }
    
    var productionText: String {
        if building.isBuilt && building.level > 0 {
            return "+\(building.productionRate)/min"
        } else if building.level == 0 {
            return "Not built yet"
        } else {
            return "Will produce +10/min"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: building.type.icon)
                    .font(.title2)
                    .foregroundColor(building.isBuilt ? .galaxyAccent : .galaxyTextSecondary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(building.name)
                        .font(GalaxyTheme.bodyFont)
                        .foregroundColor(.galaxyText)
                    
                    HStack {
                        Text("Level \(building.level)")
                            .font(GalaxyTheme.captionFont)
                            .foregroundColor(.galaxyTextSecondary)
                        
                        Spacer()
                        
                        Text(productionText)
                            .font(GalaxyTheme.captionFont)
                            .foregroundColor(building.isBuilt ? .galaxySuccess : .galaxyTextSecondary)
                    }
                    
                    if !building.isBuilt {
                        Text("Not Built • Cost: 500 credits")
                            .font(.system(size: 10))
                            .foregroundColor(.galaxyWarning)
                    } else {
                        Text("Producing \(building.type.rawValue.lowercased())")
                            .font(.system(size: 10))
                            .foregroundColor(.galaxySuccess)
                    }
                }
                
                Spacer()
                
                if building.isBuilt {
                    VStack(spacing: 4) {
                        Button("Upgrade") {
                            showingUpgrade = true
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(canAffordUpgrade ? Color.galaxyAccent : Color.galaxyTextSecondary)
                        )
                        .disabled(!canAffordUpgrade)
                        
                        Text("\(upgradeCost) credits")
                            .font(.system(size: 10))
                            .foregroundColor(canAffordUpgrade ? .galaxyText : .galaxyTextSecondary)
                    }
                } else {
                    VStack(spacing: 4) {
                        Button("Build") {
                            if gameViewModel.constructBuilding(building) {
                                // Building constructed successfully
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(canAffordConstruction ? Color.galaxySuccess : Color.galaxyTextSecondary)
                        )
                        .disabled(!canAffordConstruction)
                        
                        Text("\(constructionCost) credits")
                            .font(.system(size: 10))
                            .foregroundColor(canAffordConstruction ? .galaxyText : .galaxyTextSecondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.galaxyBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(building.isBuilt ? Color.galaxyAccent.opacity(0.3) : Color.galaxyTextSecondary.opacity(0.2), lineWidth: 1)
                )
        )
        .alert("Upgrade Building", isPresented: $showingUpgrade) {
            Button("Upgrade (\(upgradeCost) credits)") {
                if gameViewModel.upgradeBuilding(building) {
                    // Upgrade successful
                }
            }
            .disabled(!canAffordUpgrade)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Upgrade \(building.name) to level \(building.level + 1)? This will increase production to +\(building.productionRate + 5)/min.")
        }
    }
}

#Preview {
    GameView()
}
