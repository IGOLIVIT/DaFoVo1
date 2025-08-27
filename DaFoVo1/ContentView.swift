//
//  ContentView.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Main Content View
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        ZStack {
            Color.galaxyBackground
                .ignoresSafeArea()
            
            if hasCompletedOnboarding {
                GameView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            setupApp()
        }
    }
    
    private func setupApp() {
        // Setup notifications
        notificationService.setupNotifications()
        
        // Load user data
        DataLoader.shared.loadProgress()
    }
}

#Preview {
    ContentView()
}
