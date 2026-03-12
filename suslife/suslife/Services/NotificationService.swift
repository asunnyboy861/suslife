//
//  NotificationService.swift
//  suslife
//
//  Notification Service - Handles local notifications for reminders
//

import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        Task {
            await checkAuthorizationStatus()
            registerNotificationCategories()
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int) async {
        guard isAuthorized else { return }
        
        await cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "🌱 Daily Eco Reminder"
        content.body = "Don't forget to log your sustainable activities today!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            saveReminderTime(hour: hour, minute: minute)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    func scheduleWeeklySummary() async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Eco Summary"
        content.body = "Check out your weekly sustainability progress!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule weekly summary: \(error)")
        }
    }
    
    func scheduleStreakReminder() async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Keep Your Streak!"
        content.body = "You have an active streak. Log an activity today to keep it going!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule streak reminder: \(error)")
        }
    }
    
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
    
    private func saveReminderTime(hour: Int, minute: Int) {
        UserDefaults.standard.set(hour, forKey: "reminder_hour")
        UserDefaults.standard.set(minute, forKey: "reminder_minute")
    }
    
    func getSavedReminderTime() -> (hour: Int, minute: Int)? {
        let hour = UserDefaults.standard.integer(forKey: "reminder_hour")
        let minute = UserDefaults.standard.integer(forKey: "reminder_minute")
        
        if hour > 0 || minute > 0 {
            return (hour, minute)
        }
        return nil
    }
    
    func showAchievementUnlockedNotification(
        title: String,
        body: String,
        iconName: String
    ) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 0
        content.categoryIdentifier = "achievement_action"
        
        let request = UNNotificationRequest(
            identifier: "achievement_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to show achievement notification: \(error)")
        }
    }
    
    private func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func registerNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_WEEKLY",
            title: "View Summary",
            options: .foreground
        )
        
        let weeklyCategory = UNNotificationCategory(
            identifier: "weekly_summary_action",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )
        
        let viewAchievementAction = UNNotificationAction(
            identifier: "VIEW_ACHIEVEMENT",
            title: "View Achievement",
            options: .foreground
        )
        
        let achievementCategory = UNNotificationCategory(
            identifier: "achievement_action",
            actions: [viewAchievementAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            weeklyCategory,
            achievementCategory
        ])
    }
}
