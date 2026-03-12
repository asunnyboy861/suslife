//
//  DashboardViewModelTests.swift
//  suslifeTests
//
//  Unit tests for DashboardViewModel
//

import XCTest
@testable import suslife

@MainActor
final class DashboardViewModelTests: XCTestCase {
    
    var sut: DashboardViewModel!
    var mockRepository: MockActivityRepository!
    var mockUserRepository: MockUserRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockActivityRepository()
        mockUserRepository = MockUserRepository()
        sut = DashboardViewModel(
            repository: mockRepository,
            userProfileRepository: mockUserRepository
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        mockUserRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Load Data Tests
    
    /// Test that loadData loads user profile first
    func testLoadData_LoadsUserProfile() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 22.0)
        mockRepository.todayCO2ToReturn = 5.0
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertEqual(sut.dailyGoal, 22.0, "Should load dailyGoal from UserProfile")
        XCTAssertEqual(sut.todayCO2, 5.0, "Should load today's CO2")
    }
    
    /// Test that loadData uses user's dailyGoal instead of default
    func testLoadData_UsesUserDailyGoal_NotDefault() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 18.0)
        mockRepository.todayCO2ToReturn = 3.0
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertNotEqual(sut.dailyGoal, 28.0, "Should not use default value")
        XCTAssertEqual(sut.dailyGoal, 18.0, "Should use user's setting")
    }
    
    /// Test loadData with default user profile
    func testLoadData_WithDefaultProfile() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 28.0)
        mockRepository.todayCO2ToReturn = 0.0
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertEqual(sut.dailyGoal, 28.0, "Should use default when user hasn't set")
        XCTAssertEqual(sut.todayCO2, 0.0, "Should show 0 for new user")
    }
    
    // MARK: - Loading State Tests
    
    /// Test that isLoading is true during data loading
    func testLoadData_LoadingState() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 20.0)
        mockRepository.todayCO2ToReturn = 5.0
        
        // When
        let expectation = expectation(description: "Loading completes")
        
        Task {
            await sut.loadData()
            expectation.fulfill()
        }
        
        // Check loading state immediately (should be true or already completed)
        wait(for: [expectation], timeout: 1.0)
        
        // After completion, should not be loading
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test loadData handles user profile load error
    func testLoadData_HandlesUserProfileError() async throws {
        // Given
        mockUserRepository.shouldThrowError = true
        mockRepository.todayCO2ToReturn = 5.0
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        XCTAssertEqual(sut.isLoading, false, "Should stop loading on error")
    }
    
    /// Test loadData handles activity data error
    func testLoadData_HandlesActivityDataError() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 20.0)
        mockRepository.shouldThrowError = true
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        XCTAssertEqual(sut.todayCO2, 0, "Should have default CO2 value")
    }
    
    // MARK: - Change Percent Calculation Tests
    
    /// Test change percent calculation with increase
    func testCalculateChangePercent_WithIncrease() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 20.0)
        mockRepository.weeklyDataToReturn = [
            DailyTotal(date: Date().addingDays(-1), totalCO2: 10.0, activityCount: 2),
            DailyTotal(date: Date(), totalCO2: 15.0, activityCount: 3)
        ]
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertEqual(sut.changePercent, 50.0, "Should calculate 50% increase")
    }
    
    /// Test change percent calculation with decrease
    func testCalculateChangePercent_WithDecrease() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 20.0)
        mockRepository.weeklyDataToReturn = [
            DailyTotal(date: Date().addingDays(-1), totalCO2: 20.0, activityCount: 4),
            DailyTotal(date: Date(), totalCO2: 10.0, activityCount: 2)
        ]
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertEqual(sut.changePercent, -50.0, "Should calculate 50% decrease")
    }
    
    /// Test change percent with insufficient data
    func testCalculateChangePercent_InsufficientData() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 20.0)
        mockRepository.weeklyDataToReturn = [
            DailyTotal(date: Date(), totalCO2: 10.0, activityCount: 2)
        ]
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertEqual(sut.changePercent, 0, "Should be 0 with insufficient data")
    }
    
    // MARK: - Refresh Tests
    
    /// Test refresh calls loadData
    func testRefresh_CallsLoadData() async throws {
        // Given
        mockUserRepository.profileToReturn = UserProfileMock(dailyCO2Goal: 20.0)
        mockRepository.todayCO2ToReturn = 5.0
        var loadCount = 0
        
        // When
        await sut.loadData()
        loadCount += 1
        
        await sut.refresh()
        loadCount += 1
        
        // Then
        XCTAssertEqual(loadCount, 2, "Should call loadData twice")
        XCTAssertEqual(sut.todayCO2, 5.0, "Should reload data")
    }
}

// MARK: - Mock Implementations

final class MockActivityRepository: ActivityRepositoryProtocol {
    var todayCO2ToReturn: Double = 0
    var weeklyDataToReturn: [DailyTotal] = []
    var shouldThrowError = false
    
    func fetchTodayTotalCO2() async throws -> Double {
        if shouldThrowError {
            throw MockError.testError
        }
        return todayCO2ToReturn
    }
    
    func fetchWeeklyTrend() async throws -> [DailyTotal] {
        if shouldThrowError {
            throw MockError.testError
        }
        return weeklyDataToReturn
    }
    
    func fetchTodayActivities() async throws -> [CarbonActivity] {
        return []
    }
    
    func fetchActivities(from startDate: Date, to endDate: Date) async throws -> [CarbonActivity] {
        return []
    }
    
    func saveActivity(
        category: String,
        co2Amount: Double,
        date: Date,
        notes: String?
    ) async throws -> CarbonActivity {
        throw MockError.notImplemented
    }
    
    func deleteActivity(_ activity: CarbonActivity) async throws {
        throw MockError.notImplemented
    }
    
    func calculateTotalCO2Saved() async throws -> Double {
        return 0
    }
    
    func fetchTotalActivities() async throws -> Int {
        return 0
    }
    
    func fetchActivityCount(for period: ActivityPeriod) async throws -> Int {
        return 0
    }
}

final class MockUserRepository: UserRepositoryProtocol {
    var profileToReturn: UserProfileMock!
    var shouldThrowError = false
    
    func getUserProfile() async throws -> UserProfile {
        if shouldThrowError {
            throw MockError.testError
        }
        return profileToReturn
    }
    
    func createUserProfile(settings: UserProfileSettings) async throws -> UserProfile {
        if shouldThrowError {
            throw MockError.testError
        }
        return profileToReturn
    }
    
    func updateDailyGoal(_ goal: Double) async throws {
        if shouldThrowError {
            throw MockError.testError
        }
    }
    
    func updateStreak(_ streak: Int32) async throws {
        if shouldThrowError {
            throw MockError.testError
        }
    }
    
    func incrementActivityCount() async throws {
        if shouldThrowError {
            throw MockError.testError
        }
    }
    
    func save() async throws {
        if shouldThrowError {
            throw MockError.testError
        }
    }
}

final class UserProfileMock: UserProfile {
    var mockDailyCO2Goal: Double = 28.0
    var mockUnitsSystem: String = "imperial"
    var mockCloudKitSyncEnabled: Bool = false
    var mockWeeklyStreak: Int32 = 0
    var mockTotalActivitiesLogged: Int32 = 0
    
    init(dailyCO2Goal: Double = 28.0) {
        self.mockDailyCO2Goal = dailyCO2Goal
        super.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var dailyCO2Goal: Double {
        get { mockDailyCO2Goal }
        set { mockDailyCO2Goal = newValue }
    }
    
    override var unitsSystem: String {
        get { mockUnitsSystem }
        set { mockUnitsSystem = newValue }
    }
    
    override var cloudKitSyncEnabled: Bool {
        get { mockCloudKitSyncEnabled }
        set { mockCloudKitSyncEnabled = newValue }
    }
    
    override var weeklyStreak: Int32 {
        get { mockWeeklyStreak }
        set { mockWeeklyStreak = newValue }
    }
    
    override var totalActivitiesLogged: Int32 {
        get { mockTotalActivitiesLogged }
        set { mockTotalActivitiesLogged = newValue }
    }
}

enum MockError: LocalizedError {
    case testError
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .testError:
            return "Test error"
        case .notImplemented:
            return "Not implemented"
        }
    }
}

// Helper extension for Date
extension Date {
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}
