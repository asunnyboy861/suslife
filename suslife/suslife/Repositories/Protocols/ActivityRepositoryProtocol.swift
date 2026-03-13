//
//  ActivityRepositoryProtocol.swift
//  suslife
//
//  Repository Protocol - Abstracts data access
//

import Foundation

/// Defines the contract for activity data access
/// Implementations can use CoreData, SQLite, CloudKit, etc.
protocol ActivityRepositoryProtocol {
    
    // MARK: - Fetch Operations
    
    /// Fetch all activities for today
    func fetchTodayActivities() async throws -> [CarbonActivity]
    
    /// Fetch activities for a date range
    func fetchActivities(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [CarbonActivity]
    
    /// Fetch today's total CO2 emission (optimized aggregation query)
    func fetchTodayTotalCO2() async throws -> Double
    
    /// Fetch weekly trend data (7 days)
    func fetchWeeklyTrend() async throws -> [DailyTotal]
    
    // MARK: - Save Operations
    
    /// Save a new activity
    func save(_ input: ActivityInput) async throws -> CarbonActivity
    
    /// Save multiple activities (batch operation)
    func saveAll(_ activities: [ActivityInput]) async throws
    
    // MARK: - Delete Operations
    
    /// Delete an activity by ID
    func delete(id: UUID) async throws
    
    /// Delete all activities (for reset)
    func deleteAll() async throws
    
    // MARK: - Analytics
    
    /// Get user's total CO2 saved vs baseline
    func calculateTotalCO2Saved() async throws -> Double
    
    /// Get activity count for streak calculation
    func fetchActivityCount(for dateRange: DateRange) async throws -> Int
    
    /// Calculate current streak (consecutive days with activities)
    /// Returns the number of consecutive days from today backwards
    /// where the user logged at least one activity each day
    func calculateCurrentStreak() async throws -> Int
}

/// Input model for creating activities (decoupled from CoreData)
struct ActivityInput {
    let category: String
    let activityType: String
    let value: Double
    let unit: String
    let notes: String?
    let date: Date
}

/// Daily total for charts
struct DailyTotal: Identifiable {
    let id = UUID()
    let date: Date
    let totalCO2: Double
    let activityCount: Int
}

/// Date range helper
enum DateRange {
    case today
    case last7Days
    case last30Days
    case custom(start: Date, end: Date)
}

// MARK: - Achievement Support Extensions

extension ActivityRepositoryProtocol {
    
    /// Get total number of activities logged
    /// Default implementation using existing protocol methods
    func fetchTotalActivities() async throws -> Int {
        let activities = try await fetchActivities(from: .distantPast, to: Date())
        return activities.count
    }
    
    /// Get monthly trend data (last 30 days)
    /// Default implementation using existing protocol methods
    func fetchMonthlyTrend() async throws -> [DailyTotal] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -29, to: Date())!
        let activities = try await fetchActivities(from: startDate, to: Date())
        
        let grouped = Dictionary(grouping: activities) { activity in
            calendar.startOfDay(for: activity.date)
        }
        
        return grouped.map { date, activities in
            DailyTotal(
                date: date,
                totalCO2: activities.reduce(0) { $0 + $1.co2Emission },
                activityCount: activities.count
            )
        }.sorted { $0.date < $1.date }
    }
}
