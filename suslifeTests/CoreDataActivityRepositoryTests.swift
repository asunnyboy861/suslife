//
//  CoreDataActivityRepositoryTests.swift
//  suslifeTests
//
//  Repository Pattern Unit Tests
//

import XCTest
@testable import suslife

final class CoreDataActivityRepositoryTests: XCTestCase {
    
    var repository: ActivityRepositoryProtocol!
    var testCoreDataStack: CoreDataStack!
    
    override func setUp() async throws {
        testCoreDataStack = CoreDataStack.createInMemoryStack()
        repository = CoreDataActivityRepository(coreDataStack: testCoreDataStack)
    }
    
    override func tearDown() {
        testCoreDataStack = nil
        repository = nil
    }
    
    // MARK: - Save Tests
    
    func testSaveActivity() async throws {
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: 10.0,
            unit: "mi",
            notes: "Test commute",
            date: Date()
        )
        
        let activity = try await repository.save(input)
        
        XCTAssertEqual(activity.category, "transport")
        XCTAssertEqual(activity.activityType, "car")
        XCTAssertEqual(activity.value, 10.0)
        XCTAssertGreaterThan(activity.co2Emission, 0)
    }
    
    // MARK: - Fetch Tests
    
    func testFetchTodayActivities() async throws {
        // Arrange: Save 3 activities for today
        let input1 = ActivityInput(category: "transport", activityType: "car", value: 5.0, unit: "mi", notes: nil, date: Date())
        let input2 = ActivityInput(category: "food", activityType: "beef", value: 2.0, unit: "portion", notes: nil, date: Date())
        let input3 = ActivityInput(category: "transport", activityType: "bus", value: 3.0, unit: "mi", notes: nil, date: Date())
        
        try await repository.save(input1)
        try await repository.save(input2)
        try await repository.save(input3)
        
        // Act
        let activities = try await repository.fetchTodayActivities()
        
        // Assert
        XCTAssertEqual(activities.count, 3)
    }
    
    func testFetchTodayTotalCO2() async throws {
        // Arrange
        let input = ActivityInput(category: "transport", activityType: "car", value: 10.0, unit: "mi", notes: nil, date: Date())
        try await repository.save(input)
        
        // Act
        let total = try await repository.fetchTodayTotalCO2()
        
        // Assert: 10 miles * 0.13 lbs/mile = 1.3 lbs
        XCTAssertEqual(total, 1.3, accuracy: 0.01)
    }
    
    func testFetchWeeklyTrend() async throws {
        // Arrange: Create activities for past 7 days
        let calendar = Calendar.current
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            
            let input = ActivityInput(
                category: "transport",
                activityType: "car",
                value: Double(i + 1),
                unit: "mi",
                notes: nil,
                date: date
            )
            
            try await repository.save(input)
        }
        
        // Act
        let trend = try await repository.fetchWeeklyTrend()
        
        // Assert
        XCTAssertEqual(trend.count, 7)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteActivity() async throws {
        // Arrange
        let input = ActivityInput(category: "transport", activityType: "car", value: 5.0, unit: "mi", notes: nil, date: Date())
        let activity = try await repository.save(input)
        
        // Act
        try await repository.delete(id: activity.id)
        
        // Assert
        let activities = try await repository.fetchTodayActivities()
        XCTAssertTrue(activities.isEmpty)
    }
    
    func testDeleteAllActivities() async throws {
        // Arrange: Save 5 activities
        for i in 0..<5 {
            let input = ActivityInput(
                category: "transport",
                activityType: "car",
                value: Double(i),
                unit: "mi",
                notes: nil,
                date: Date()
            )
            try await repository.save(input)
        }
        
        // Act
        try await repository.deleteAll()
        
        // Assert
        let activities = try await repository.fetchTodayActivities()
        XCTAssertTrue(activities.isEmpty)
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentSaveOperations() async throws {
        // Save 10 activities concurrently
        let tasks = (1...10).map { i in
            Task {
                let input = ActivityInput(
                    category: "transport",
                    activityType: "car",
                    value: Double(i),
                    unit: "mi",
                    notes: nil,
                    date: Date()
                )
                return try await repository.save(input)
            }
        }
        
        let activities = try await withTaskGroup(of: CarbonActivity.self) { group in
            for task in tasks {
                group.addTask {
                    await task.value
                }
            }
            
            var results: [CarbonActivity] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        XCTAssertEqual(activities.count, 10)
        
        // Verify all saved correctly
        let fetched = try await repository.fetchTodayActivities()
        XCTAssertEqual(fetched.count, 10)
    }
    
    // MARK: - Analytics Tests
    
    func testCalculateTotalCO2Saved() async throws {
        // This test depends on baseline calculation
        // For now, just verify it doesn't crash
        let total = try await repository.calculateTotalCO2Saved()
        XCTAssertGreaterThanOrEqual(total, 0)
    }
}
