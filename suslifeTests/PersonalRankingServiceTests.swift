//
//  PersonalRankingServiceTests.swift
//  suslifeTests
//
//  Tests for PersonalRankingService
//

import XCTest
@testable import suslife

@MainActor
final class PersonalRankingServiceTests: XCTestCase {
    
    var sut: PersonalRankingService!
    
    override func setUp() async throws {
        sut = PersonalRankingService()
    }
    
    override func tearDown() async throws {
        sut = nil
    }
    
    func testLoadCurrentWeekPerformance_WithNoData() async throws {
        // When: No data logged
        try await sut.loadCurrentWeekPerformance()
        
        // Then: Should have 0 activities
        XCTAssertNotNil(sut.currentWeekPerformance)
        XCTAssertEqual(sut.currentWeekPerformance?.activityCount, 0)
        XCTAssertEqual(sut.currentWeekPerformance?.totalCO2, 0.0, accuracy: 0.01)
        XCTAssertEqual(sut.currentWeekPerformance?.period, .weekly)
    }
    
    func testPerformanceComparison_ChangePercent() async {
        // Given: Create comparison data
        let current = PersonalPerformance(
            period: .weekly,
            totalCO2: 20.0,
            activityCount: 5,
            averagePerDay: 2.86
        )
        let previous = PersonalPerformance(
            period: .weekly,
            totalCO2: 25.0,
            activityCount: 6,
            averagePerDay: 3.57
        )
        
        let comparison = PerformanceComparison(
            current: current,
            previous: previous,
            best: nil
        )
        
        // Then: Change percent should be -20%
        XCTAssertEqual(comparison.changePercent, -20.0, accuracy: 0.01)
        XCTAssertTrue(comparison.isImproved)
        XCTAssertEqual(comparison.changeDescription, "↓ 20.0%")
    }
    
    func testPerformanceComparison_NoImprovement() async {
        // Given: Worse performance
        let current = PersonalPerformance(
            period: .weekly,
            totalCO2: 30.0,
            activityCount: 5,
            averagePerDay: 4.29
        )
        let previous = PersonalPerformance(
            period: .weekly,
            totalCO2: 25.0,
            activityCount: 6,
            averagePerDay: 3.57
        )
        
        let comparison = PerformanceComparison(
            current: current,
            previous: previous,
            best: nil
        )
        
        // Then: Should show increase (worse)
        XCTAssertEqual(comparison.changePercent, 20.0, accuracy: 0.01)
        XCTAssertFalse(comparison.isImproved)
        XCTAssertEqual(comparison.changeDescription, "↑ 20.0%")
    }
    
    func testPercentileRanking_Top10() {
        // When: 95th percentile
        let ranking = PercentileRanking.from(percentile: 95.0)
        
        // Then: Should be Top 10%
        XCTAssertEqual(ranking.rank, "Top 10%")
        XCTAssertEqual(ranking.icon, "trophy.fill")
        XCTAssertTrue(ranking.message.contains("90%"))
    }
    
    func testPercentileRanking_Great() {
        // When: 75th percentile
        let ranking = PercentileRanking.from(percentile: 75.0)
        
        // Then: Should be Great
        XCTAssertEqual(ranking.rank, "Great")
        XCTAssertEqual(ranking.icon, "star.fill")
        XCTAssertTrue(ranking.message.contains("Great job"))
    }
    
    func testPercentileRanking_Good() {
        // When: 60th percentile
        let ranking = PercentileRanking.from(percentile: 60.0)
        
        // Then: Should be Good
        XCTAssertEqual(ranking.rank, "Good")
        XCTAssertEqual(ranking.icon, "checkmark.circle.fill")
        XCTAssertTrue(ranking.message.contains("Good effort"))
    }
    
    func testPercentileRanking_KeepGoing() {
        // When: 45th percentile
        let ranking = PercentileRanking.from(percentile: 45.0)
        
        // Then: Should be Keep Going
        XCTAssertEqual(ranking.rank, "Keep Going")
        XCTAssertEqual(ranking.icon, "leaf.fill")
        XCTAssertTrue(ranking.message.contains("Every step counts"))
    }
    
    func testPersonalPerformance_FormattedCO2() {
        // Given: Performance with 123.456 lbs
        let performance = PersonalPerformance(
            period: .weekly,
            totalCO2: 123.456,
            activityCount: 5,
            averagePerDay: 17.64
        )
        
        // Then: Should format to 1 decimal place
        XCTAssertEqual(performance.formattedCO2, "123.5 lbs")
    }
    
    func testPerformanceComparison_NoPrevious() async {
        // Given: No previous data
        let current = PersonalPerformance(
            period: .weekly,
            totalCO2: 20.0,
            activityCount: 5,
            averagePerDay: 2.86
        )
        
        let comparison = PerformanceComparison(
            current: current,
            previous: nil,
            best: nil
        )
        
        // Then: Change percent should be 0
        XCTAssertEqual(comparison.changePercent, 0)
        XCTAssertFalse(comparison.isImproved)
        XCTAssertEqual(comparison.changeDescription, "No change")
    }
    
    func testPerformancePeriod_RawValue() {
        // Test enum raw values
        XCTAssertEqual(PerformancePeriod.weekly.rawValue, "Week")
        XCTAssertEqual(PerformancePeriod.monthly.rawValue, "Month")
        XCTAssertEqual(PerformancePeriod.yearly.rawValue, "Year")
    }
}
