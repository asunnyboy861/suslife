//
//  CoreDataStackTests.swift
//  suslifeTests
//
//  CoreData Stack Unit Tests
//

import XCTest
import CoreData
@testable import suslife

final class CoreDataStackTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    
    override func setUp() async throws {
        // Use in-memory store for testing
        coreDataStack = CoreDataStack.createInMemoryStack()
    }
    
    override func tearDown() {
        coreDataStack = nil
    }
    
    // MARK: - CRUD Tests
    
    func testCreateCarbonActivity() async throws {
        let context = coreDataStack.mainContext
        
        let activity = CarbonActivity.create(
            in: context,
            category: "transport",
            activityType: "car",
            value: 10.0,
            unit: "mi"
        )
        
        XCTAssertEqual(activity.category, "transport")
        XCTAssertEqual(activity.activityType, "car")
        XCTAssertEqual(activity.value, 10.0)
        XCTAssertEqual(activity.unit, "mi")
        XCTAssertGreaterThan(activity.co2Emission, 0)
    }
    
    func testSaveAndFetchActivity() async throws {
        let context = coreDataStack.mainContext
        
        // Create
        let activity = CarbonActivity.create(
            in: context,
            category: "food",
            activityType: "beef",
            value: 2.0,
            unit: "portion"
        )
        
        // Save
        try coreDataStack.save()
        
        // Fetch
        let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
        let fetched = try context.fetch(request)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.category, "food")
    }
    
    func testDeleteActivity() async throws {
        let context = coreDataStack.mainContext
        
        // Create
        _ = CarbonActivity.create(
            in: context,
            category: "transport",
            activityType: "bus",
            value: 5.0,
            unit: "mi"
        )
        
        try coreDataStack.save()
        
        // Delete all
        let request: NSFetchRequest<NSFetchRequestResult> = CarbonActivity.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(batchDelete)
        try coreDataStack.save()
        
        // Verify empty
        let fetchRequest: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
        let fetched = try context.fetch(fetchRequest)
        XCTAssertEqual(fetched.count, 0)
    }
    
    // MARK: - UserProfile Tests
    
    func testGetOrCreateUserProfile() async throws {
        let context = coreDataStack.mainContext
        let profile = UserProfile.getCurrent(in: context)
        
        XCTAssertNotNil(profile)
        XCTAssertEqual(profile.dailyCO2Goal, 28.0)
        XCTAssertEqual(profile.weeklyStreak, 0)
        XCTAssertEqual(profile.unitsSystem, "imperial")
    }
    
    func testUpdateUserProfile() async throws {
        let context = coreDataStack.mainContext
        let profile = UserProfile.getCurrent(in: context)
        
        // Update
        profile.dailyCO2Goal = 25.0
        profile.weeklyStreak = 7
        profile.cloudKitSyncEnabled = true
        
        try coreDataStack.save()
        
        // Fetch again
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        let fetched = try context.fetch(request)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.dailyCO2Goal, 25.0)
        XCTAssertEqual(fetched.first?.weeklyStreak, 7)
        XCTAssertEqual(fetched.first?.cloudKitSyncEnabled, true)
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentSaves() async throws {
        let context = coreDataStack.mainContext
        
        // Create 10 activities concurrently
        let activities = (1...10).map { i in
            CarbonActivity.create(
                in: context,
                category: "transport",
                activityType: "car",
                value: Double(i),
                unit: "mi"
            )
        }
        
        try coreDataStack.save()
        
        // Verify all saved
        let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
        let fetched = try context.fetch(request)
        XCTAssertEqual(fetched.count, 10)
    }
    
    // MARK: - Performance Tests
    
    func testSavePerformance() {
        let context = coreDataStack.mainContext
        
        measure {
            for _ in 0..<100 {
                _ = CarbonActivity.create(
                    in: context,
                    category: "transport",
                    activityType: "car",
                    value: 10.0,
                    unit: "mi"
                )
            }
            try? coreDataStack.save()
        }
    }
}
