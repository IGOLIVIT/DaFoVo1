//
//  NotificationService.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Notification Management
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Mission Reminders
    func scheduleDailyMissionReminder() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Galaxy Finance Quest"
        content.body = "Your colony needs attention! Complete daily missions to earn rewards."
        content.sound = .default
        content.badge = 1
        
        // Schedule for 7 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_mission_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleResourceLowNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Resource Alert!"
        content.body = "Your colony resources are running low. Check your colony status."
        content.sound = .default
        content.badge = 1
        
        // Schedule for 30 seconds from now (for testing purposes)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: "resource_low_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule resource notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleMissionCompleteNotification(missionTitle: String, rewards: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Mission Complete!"
        content.body = "You completed '\(missionTitle)' and earned \(rewards) credits!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "mission_complete_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule mission complete notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleAchievementUnlockedNotification(achievementTitle: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = "You earned the '\(achievementTitle)' achievement!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "achievement_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule achievement notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleLevelUpNotification(newLevel: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Level Up!"
        content.body = "Congratulations! You reached level \(newLevel)!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "level_up_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule level up notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Educational Reminders
    func scheduleWeeklyLearningReminder() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Finance Tip"
        content.body = "Learn something new! Check out this week's financial education content."
        content.sound = .default
        content.badge = 1
        
        // Schedule for Sunday at 10 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_learning_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule weekly learning reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Utility Methods
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Setup
    func setupNotifications() {
        if isAuthorized {
            scheduleDailyMissionReminder()
            scheduleWeeklyLearningReminder()
        } else {
            requestAuthorization()
        }
    }
}

