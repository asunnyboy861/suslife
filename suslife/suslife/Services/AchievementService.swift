//
//  AchievementService.swift
//  suslife
//
//  Achievement Service - Manages achievement checking and unlocking
//

import Foundation

@MainActor
final class AchievementService: ObservableObject {
    @Published private(set) var achievements: [Achievement] = Achievement.allAchievements
    @Published private(set) var recentlyUnlocked: [Achievement] = []
    @Published private(set) var totalXP: Int = 0
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol) {
        self.repository = repository
        loadXP()
    }
    
    func checkAchievements() async {
        var newlyUnlocked: [Achievement] = []
        
        do {
            let totalActivities = try await repository.fetchTotalActivities()
            let totalCO2Saved = try await repository.calculateTotalCO2Saved()
            let streak = try await repository.fetchActivityCount(for: .last7Days)
            let monthlyTrend = try await repository.fetchMonthlyTrend()
            
            for index in achievements.indices {
                let achievement = achievements[index]
                if achievement.isUnlocked { continue }
                
                let shouldUnlock = checkRequirement(
                    achievement.requirement,
                    totalActivities: totalActivities,
                    totalCO2Saved: totalCO2Saved,
                    streakDays: streak,
                    monthlyTrend: monthlyTrend
                )
                
                if shouldUnlock {
                    unlockAchievement(at: index)
                    newlyUnlocked.append(achievements[index])
                    totalXP += achievements[index].xpReward
                } else {
                    updateProgress(
                        at: index,
                        totalActivities: totalActivities,
                        totalCO2Saved: totalCO2Saved,
                        streakDays: streak,
                        monthlyTrend: monthlyTrend
                    )
                }
            }
            
            if !newlyUnlocked.isEmpty {
                recentlyUnlocked = newlyUnlocked
                saveXP()
            }
        } catch {
            print("Error checking achievements: \(error)")
        }
    }
    
    private func checkRequirement(
        _ requirement: AchievementRequirement,
        totalActivities: Int,
        totalCO2Saved: Double,
        streakDays: Int,
        monthlyTrend: [DailyTotal]
    ) -> Bool {
        switch requirement {
        case .totalActivities(let count):
            return totalActivities >= count
        case .streakDays(let days):
            return streakDays >= days
        case .totalCO2Saved(let kg):
            return totalCO2Saved >= kg
        case .weeklyActivities(_, let count):
            return weeklyActivitiesCount(monthlyTrend) >= count
        case .categoryMilestone:
            return false
        case .consecutiveDays(let days):
            return calculateConsecutiveDays(monthlyTrend) >= days
        }
    }
    
    private func updateProgress(
        at index: Int,
        totalActivities: Int,
        totalCO2Saved: Double,
        streakDays: Int,
        monthlyTrend: [DailyTotal]
    ) {
        let achievement = achievements[index]
        var progress: Double = 0
        
        switch achievement.requirement {
        case .totalActivities(let count):
            progress = min(Double(totalActivities) / Double(count), 1.0)
        case .streakDays(let days):
            progress = min(Double(streakDays) / Double(days), 1.0)
        case .totalCO2Saved(let kg):
            progress = min(totalCO2Saved / kg, 1.0)
        case .weeklyActivities(_, let count):
            progress = min(Double(weeklyActivitiesCount(monthlyTrend)) / Double(count), 1.0)
        case .categoryMilestone:
            progress = 0
        case .consecutiveDays(let days):
            progress = min(Double(calculateConsecutiveDays(monthlyTrend)) / Double(days), 1.0)
        }
        
        achievement.progress = progress
    }
    
    private func weeklyActivitiesCount(_ trend: [DailyTotal]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: now) else { return 0 }
        
        return trend
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.activityCount }
    }
    
    private func calculateConsecutiveDays(_ trend: [DailyTotal]) -> Int {
        guard !trend.isEmpty else { return 0 }
        
        let sorted = trend.sorted { $0.date > $1.date }
        var consecutive = 0
        let calendar = Calendar.current
        var expectedDate = calendar.startOfDay(for: Date())
        
        for daily in sorted {
            let dayStart = calendar.startOfDay(for: daily.date)
            if dayStart == expectedDate || dayStart == calendar.date(byAdding: .day, value: -1, to: expectedDate) {
                consecutive += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: dayStart)!
            } else {
                break
            }
        }
        
        return consecutive
    }
    
    private func unlockAchievement(at index: Int) {
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
    }
    
    func clearRecentlyUnlocked() {
        recentlyUnlocked = []
    }
    
    private func loadXP() {
        totalXP = UserDefaults.standard.integer(forKey: "total_xp")
    }
    
    private func saveXP() {
        UserDefaults.standard.set(totalXP, forKey: "total_xp")
    }
    
    func getUnlockedCount() -> Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    func getProgressPercentage() -> Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(getUnlockedCount()) / Double(achievements.count)
    }
}
