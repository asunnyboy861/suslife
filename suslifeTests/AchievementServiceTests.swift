//
//  AchievementServiceTests.swift
//  suslifeTests
//
//  Achievement Service Tests
//

import XCTest
@testable import suslife

final class AchievementServiceTests: XCTestCase {
    
    var achievementService: AchievementService!
    var mockRepository: MockActivityRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockActivityRepository()
        achievementService = AchievementService(repository: mockRepository)
        
        UserDefaults.standard.removeObject(forKey: "total_xp")
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: "total_xp")
    }
    
    func testInitialXPIsZero() {
        XCTAssertEqual(achievementService.totalXP, 0)
    }
    
    func testAllAchievementsLoaded() {
        XCTAssertFalse(achievementService.achievements.isEmpty)
    }
}

final class MockActivityRepository: ActivityRepositoryProtocol {
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
        return []
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
        return 0
    }
    
    func fetchActivityCount(for dateRange: DateRange) async throws -> Int {
        return 0
    }
}
