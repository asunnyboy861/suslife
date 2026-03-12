//
//  LocalUserRepositoryTests.swift
//  suslifeTests
//
//  Unit tests for LocalUserRepository
//

import XCTest
@testable import suslife

@MainActor
final class LocalUserRepositoryTests: XCTestCase {
    
    var sut: LocalUserRepository!
    var stack: CoreDataStack!
    
    override func setUp() async throws {
        try await super.setUp()
        stack = CoreDataStack.createInMemoryStack()
        sut = LocalUserRepository(coreDataStack: stack)
    }
    
    override func tearDown() async throws {
        sut = nil
        stack = nil
        try await super.tearDown()
    }
    
    // MARK: - Create User Profile Tests
    
    /// Test creating user profile with settings
    func testCreateUserProfile_WithSettings() async throws {
        // Given
        let settings = UserProfileSettings(
            dailyCO2Goal: 25.0,
            notificationsEnabled: true,
            healthKitEnabled: false,
            unitsSystem: "imperial"
        )
        
        // When
        let profile = try await sut.createUserProfile(settings: settings)
        
        // Then
        XCTAssertEqual(profile.dailyCO2Goal, 25.0, "Daily goal should match settings")
        XCTAssertEqual(profile.unitsSystem, "imperial", "Units system should match settings")
        XCTAssertEqual(profile.weeklyStreak, 0, "Initial streak should be 0")
        XCTAssertEqual(profile.totalActivitiesLogged, 0, "Initial activities should be 0")
    }
    
    /// Test that creating profile twice returns the same profile (singleton pattern)
    func testCreateUserProfile_Twice_ReturnsSameProfile() async throws {
        // Given
        let settings1 = UserProfileSettings(
            dailyCO2Goal: 20.0,
            notificationsEnabled: false,
            healthKitEnabled: false,
            unitsSystem: "imperial"
        )
        
        let settings2 = UserProfileSettings(
            dailyCO2Goal: 30.0,
            notificationsEnabled: true,
            healthKitEnabled: true,
            unitsSystem: "imperial"
        )
        
        // When
        let profile1 = try await sut.createUserProfile(settings: settings1)
        let profile2 = try await sut.createUserProfile(settings: settings2)
        
        // Then
        XCTAssertEqual(profile1.id, profile2.id, "Should return the same profile instance")
        XCTAssertEqual(profile2.dailyCO2Goal, 30.0, "Should update the goal to new value")
    }
    
    // MARK: - Update Daily Goal Tests
    
    /// Test updating daily goal
    func testUpdateDailyGoal() async throws {
        // Given
        let settings = UserProfileSettings(
            dailyCO2Goal: 20.0,
            notificationsEnabled: false,
            healthKitEnabled: false,
            unitsSystem: "imperial"
        )
        _ = try await sut.createUserProfile(settings: settings)
        
        // When
        try await sut.updateDailyGoal(35.0)
        
        // Then
        let profile = try await sut.getUserProfile()
        XCTAssertEqual(profile.dailyCO2Goal, 35.0, "Daily goal should be updated")
    }
    
    // MARK: - Get User Profile Tests
    
    /// Test getting user profile when none exists (should create default)
    func testGetUserProfile_WhenNoneExists_CreatesDefault() async throws {
        // When
        let profile = try await sut.getUserProfile()
        
        // Then
        XCTAssertNotNil(profile, "Profile should be created")
        XCTAssertEqual(profile.dailyCO2Goal, 28.0, "Default goal should be 28.0")
        XCTAssertEqual(profile.unitsSystem, "imperial", "Default units should be imperial")
    }
    
    /// Test getting user profile after creation
    func testGetUserProfile_AfterCreation_ReturnsCorrectProfile() async throws {
        // Given
        let settings = UserProfileSettings(
            dailyCO2Goal: 22.0,
            notificationsEnabled: true,
            healthKitEnabled: true,
            unitsSystem: "metric"
        )
        _ = try await sut.createUserProfile(settings: settings)
        
        // When
        let profile = try await sut.getUserProfile()
        
        // Then
        XCTAssertEqual(profile.dailyCO2Goal, 22.0, "Should return correct daily goal")
        XCTAssertEqual(profile.cloudKitSyncEnabled, true, "Should return correct sync setting")
        XCTAssertEqual(profile.unitsSystem, "metric", "Should return correct units system")
    }
    
    // MARK: - Update Streak Tests
    
    /// Test updating weekly streak
    func testUpdateStreak() async throws {
        // Given
        let settings = UserProfileSettings(
            dailyCO2Goal: 20.0,
            notificationsEnabled: false,
            healthKitEnabled: false,
            unitsSystem: "imperial"
        )
        _ = try await sut.createUserProfile(settings: settings)
        
        // When
        try await sut.updateStreak(5)
        
        // Then
        let profile = try await sut.getUserProfile()
        XCTAssertEqual(profile.weeklyStreak, 5, "Streak should be updated")
    }
    
    // MARK: - Increment Activity Count Tests
    
    /// Test incrementing activity count
    func testIncrementActivityCount() async throws {
        // Given
        let settings = UserProfileSettings(
            dailyCO2Goal: 20.0,
            notificationsEnabled: false,
            healthKitEnabled: false,
            unitsSystem: "imperial"
        )
        _ = try await sut.createUserProfile(settings: settings)
        
        // When
        try await sut.incrementActivityCount()
        try await sut.incrementActivityCount()
        try await sut.incrementActivityCount()
        
        // Then
        let profile = try await sut.getUserProfile()
        XCTAssertEqual(profile.totalActivitiesLogged, 3, "Should increment activity count")
    }
}
