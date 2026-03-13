//
//  PersonalRankingService.swift
//  suslife
//
//  Personal Ranking Service - Track and compare your personal progress
//

import Foundation

@MainActor
final class PersonalRankingService: ObservableObject {
    @Published var currentWeekPerformance: PersonalPerformance?
    @Published var performanceComparison: PerformanceComparison?
    @Published var percentileRanking: PercentileRanking?
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol = CoreDataActivityRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Load current week performance data
    func loadCurrentWeekPerformance() async throws {
        let calendar = Calendar.current
        let now = Date()
        // Get start of week (Monday)
        var startOfWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        startOfWeekComponents.weekday = calendar.firstWeekday
        let startOfWeek = calendar.date(from: startOfWeekComponents) ?? now
        
        let activities = try await repository.fetchActivities(
            from: startOfWeek,
            to: now
        )
        
        let totalCO2 = activities.reduce(0.0) { $0 + $1.co2Emission }
        let daysSoFar = max(1, calendar.dateComponents([.day], from: startOfWeek, to: now).day ?? 1)
        let averagePerDay = totalCO2 / Double(daysSoFar)
        
        currentWeekPerformance = PersonalPerformance(
            period: .weekly,
            totalCO2: totalCO2,
            activityCount: activities.count,
            averagePerDay: averagePerDay
        )
    }
    
    /// Load historical comparison data
    func loadPerformanceComparison() async throws {
        let calendar = Calendar.current
        let now = Date()
        // Get start of week (Monday)
        var startOfWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        startOfWeekComponents.weekday = calendar.firstWeekday
        let startOfWeek = calendar.date(from: startOfWeekComponents) ?? now
        
        // Current week
        let currentWeekActivities = try await repository.fetchActivities(
            from: startOfWeek,
            to: now
        )
        let currentWeekCO2 = currentWeekActivities.reduce(0.0) { $0 + $1.co2Emission }
        
        // Last week
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek)!
        let lastWeekActivities = try await repository.fetchActivities(
            from: lastWeekStart,
            to: startOfWeek
        )
        let lastWeekCO2 = lastWeekActivities.reduce(0.0) { $0 + $1.co2Emission }
        
        // Best week (past 12 weeks)
        let twelveWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -12, to: startOfWeek)!
        let allActivities = try await repository.fetchActivities(
            from: twelveWeeksAgo,
            to: now
        )
        
        let weeklyTotals = Dictionary(grouping: allActivities) { activity in
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: activity.date)
        }.mapValues { $0.reduce(0.0) { $0 + $1.co2Emission } }
        
        let bestWeekCO2 = weeklyTotals.values.max() ?? 0
        
        // Build comparison objects
        let current = PersonalPerformance(
            period: .weekly,
            totalCO2: currentWeekCO2,
            activityCount: currentWeekActivities.count,
            averagePerDay: currentWeekCO2 / 7
        )
        
        let previous = lastWeekCO2 > 0 ? PersonalPerformance(
            period: .weekly,
            totalCO2: lastWeekCO2,
            activityCount: lastWeekActivities.count,
            averagePerDay: lastWeekCO2 / 7
        ) : nil
        
        let best = bestWeekCO2 > 0 ? PersonalPerformance(
            period: .weekly,
            totalCO2: bestWeekCO2,
            activityCount: 0,
            averagePerDay: bestWeekCO2 / 7
        ) : nil
        
        performanceComparison = PerformanceComparison(
            current: current,
            previous: previous,
            best: best
        )
    }
    
    /// Calculate percentile ranking
    func calculatePercentileRanking() async throws {
        guard let current = currentWeekPerformance else { return }
        
        let calendar = Calendar.current
        let now = Date()
        // Get start of week (Monday)
        var startOfWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        startOfWeekComponents.weekday = calendar.firstWeekday
        let startOfWeek = calendar.date(from: startOfWeekComponents) ?? now
        let twelveWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -12, to: startOfWeek)!
        
        let allActivities = try await repository.fetchActivities(
            from: twelveWeeksAgo,
            to: now
        )
        
        let weeklyTotals = Dictionary(grouping: allActivities) { activity in
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: activity.date)
        }.mapValues { $0.reduce(0.0) { $0 + $1.co2Emission } }
        
        let allWeeks = Array(weeklyTotals.values)
        let weeksWithLessCO2 = allWeeks.filter { $0 < current.totalCO2 }.count
        
        let percentile = allWeeks.isEmpty ? 0 : 
            Double(weeksWithLessCO2) / Double(allWeeks.count) * 100
        
        percentileRanking = PercentileRanking.from(percentile: percentile)
    }
    
    /// Get personalized encouragement message
    func getEncouragementMessage() -> String {
        guard let ranking = percentileRanking else {
            return "Start logging activities to see your progress!"
        }
        return ranking.message
    }
}

// MARK: - Data Models

/// Personal performance data
struct PersonalPerformance {
    let period: PerformancePeriod
    let totalCO2: Double
    let activityCount: Int
    let averagePerDay: Double
    
    var formattedCO2: String {
        String(format: "%.1f lbs", totalCO2)
    }
}

/// Performance comparison result
struct PerformanceComparison {
    let current: PersonalPerformance
    let previous: PersonalPerformance?
    let best: PersonalPerformance?
    
    var changePercent: Double {
        guard let previous = previous, previous.totalCO2 > 0 else { return 0 }
        return ((current.totalCO2 - previous.totalCO2) / previous.totalCO2) * 100
    }
    
    var isImproved: Bool {
        changePercent < 0  // Negative means better (more CO2 saved)
    }
    
    var changeDescription: String {
        if changePercent == 0 { return "No change" }
        let sign = changePercent < 0 ? "↓" : "↑"
        return "\(sign) \(String(format: "%.1f", abs(changePercent)))%"
    }
}

/// Time period for performance tracking
enum PerformancePeriod: String, Codable {
    case weekly = "Week"
    case monthly = "Month"
    case yearly = "Year"
}

/// Percentile ranking result
struct PercentileRanking {
    let percentile: Double
    let rank: String
    let message: String
    let icon: String
    
    static func from(percentile: Double) -> PercentileRanking {
        switch percentile {
        case 90...:
            return PercentileRanking(
                percentile: percentile,
                rank: "Top 10%",
                message: "Best performance ever! You're beating 90% of your history!",
                icon: "trophy.fill"
            )
        case 70..<90:
            return PercentileRanking(
                percentile: percentile,
                rank: "Great",
                message: "Great job! Better than most of your history!",
                icon: "star.fill"
            )
        case 50..<70:
            return PercentileRanking(
                percentile: percentile,
                rank: "Good",
                message: "Good effort! Above average!",
                icon: "checkmark.circle.fill"
            )
        default:
            return PercentileRanking(
                percentile: percentile,
                rank: "Keep Going",
                message: "Keep going! Every step counts!",
                icon: "leaf.fill"
            )
        }
    }
}
