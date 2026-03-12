//
//  AchievementServiceTests.swift
//  suslifeTests
//
//  Achievement Service Tests
//

import XCTest
@testable import suslife

@MainActor
final class AchievementServiceTests: XCTestCase {
    
    var achievementService: AchievementService!
    var mockRepository: MockActivityRepository!
    var mockNotificationService: MockNotificationService!
    
    override func setUp() async throws {
        mockRepository = MockActivityRepository()
        mockNotificationService = MockNotificationService()
        achievementService = AchievementService(
            repository: mockRepository,
            notificationService: mockNotificationService
        )
        
        UserDefaults.standard.removeObject(forKey: "total_xp")
    }
    
    override func tearDown() async throws {
        UserDefaults.standard.removeObject(forKey: "total_xp")
    }
    
    func testInitialXPIsZero() {
        XCTAssertEqual(achievementService.totalXP, 0)
    }
    
    func testAllAchievementsLoaded() {
        XCTAssertFalse(achievementService.achievements.isEmpty)
    }
    
    func testFirstActivityAchievement() async throws {
        mockRepository.totalActivities = 1
        
        await achievementService.checkAchievements()
        
        let firstStepAchievement = achievementService.achievements.first { $0.id == "first_log" }
        XCTAssertTrue(firstStepAchievement?.isUnlocked ?? false)
    }
    
    func testAchievementPopupTriggered() async throws {
        mockRepository.totalActivities = 1
        
        await achievementService.checkAchievements()
        
        XCTAssertTrue(achievementService.showUnlockPopup)
        XCTAssertNotNil(achievementService.currentUnlockAchievement)
    }
    
    func testXPAccumulation() async throws {
        mockRepository.totalActivities = 1
        await achievementService.checkAchievements()
        let initialXP = achievementService.totalXP
        
        mockRepository.totalActivities = 10
        await achievementService.checkAchievements()
        
        XCTAssertGreaterThan(achievementService.totalXP, initialXP)
    }
    
    func testProgressUpdates() async throws {
        mockRepository.totalActivities = 5
        
        await achievementService.checkAchievements()
        
        let tenActivitiesAchievement = achievementService.achievements.first { $0.id == "ten_activities" }
        XCTAssertEqual(tenActivitiesAchievement?.progress, 0.5, accuracy: 0.01)
        XCTAssertFalse(tenActivitiesAchievement?.isUnlocked ?? true)
    }
    
    func testNotificationSentOnUnlock() async throws {
        mockNotificationService.isAuthorized = true
        mockRepository.totalActivities = 1
        
        await achievementService.checkAchievements()
        
        XCTAssertTrue(mockNotificationService.notificationSent)
        XCTAssertEqual(mockNotificationService.lastTitle, "Achievement Unlocked!")
    }
}

@MainActor
final class MockNotificationService: ObservableObject {
    var isAuthorized = false
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var notificationSent = false
    var lastTitle: String?
    var lastBody: String?
    
    func checkAuthorizationStatus() async {}
    
    func requestAuthorization() async -> Bool {
        isAuthorized = true
        return true
    }
    
    func showAchievementUnlockedNotification(
        title: String,
        body: String,
        iconName: String
    ) async {
        notificationSent = true
        lastTitle = title
        lastBody = body
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int) async {}
    
    func scheduleWeeklySummary() async {}
    
    func scheduleStreakReminder() async {}
    
    func cancelAllNotifications() async {}
    
    func cancelDailyReminder() {}
    
    func clearBadge() {}
    
    func getSavedReminderTime() -> (hour: Int, minute: Int)? { nil }
    
    func registerNotificationCategories() {}
}

final class MockActivityRepository: ActivityRepositoryProtocol {
    var totalActivities = 0
    var totalCO2Saved: Double = 0
    var streakDays = 0
    var monthlyTrend: [DailyTotal] = []
    
    func fetchTodayActivities() async throws -> [CarbonActivity] {
        return []
    }
    
    func fetchActivities(from startDate: Date, to endDate: Date) async throws -> [CarbonActivity] {
        return []
    }
    
    func fetchTodayTotalCO2() async throws -> Double {
        return 0
    }
    
    func fetchWeeklyTrend() async throws -> [DailyTotal] {
        return monthlyTrend
    }
    
    func save(_ input: ActivityInput) async throws -> CarbonActivity {
        return CarbonActivity()
    }
    
    func saveAll(_ activities: [ActivityInput]) async throws {
    }
    
    func delete(id: UUID) async throws {
    }
    
    func deleteAll() async throws {
    }
    
    func calculateTotalCO2Saved() async throws -> Double {
        return totalCO2Saved
    }
    
    func fetchActivityCount(for dateRange: DateRange) async throws -> Int {
        return totalActivities
    }
    
    func fetchTotalActivities() async throws -> Int {
        return totalActivities
    }
    
    func fetchMonthlyTrend() async throws -> [DailyTotal] {
        return monthlyTrend
    }
}
