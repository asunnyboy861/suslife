//
//  RankingService.swift
//  suslife
//
//  Ranking Service - Local leaderboard functionality
//

import Foundation

struct LeaderboardEntry: Identifiable, Codable {
    let id: String
    let displayName: String
    let avatarName: String
    var totalCO2Saved: Double
    var totalActivities: Int
    var currentStreak: Int
    var rank: Int
    
    var formattedCO2: String {
        String(format: "%.0f lbs", totalCO2Saved)
    }
}

final class RankingService: ObservableObject {
    @Published var currentRank: Int = 0
    @Published var weeklyRank: Int = 0
    @Published var allTimeRank: Int = 0
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol = CoreDataActivityRepository()) {
        self.repository = repository
    }
    
    func calculateRanking() async throws -> Int {
        let totalCO2Saved = try await repository.calculateTotalCO2Saved()
        return calculateRankFromCO2(totalCO2Saved)
    }
    
    func getLeaderboard(limit: Int = 10) async throws -> [LeaderboardEntry] {
        let userCO2Saved = try await repository.calculateTotalCO2Saved()
        let userActivities = try await repository.fetchTotalActivities()
        let userStreak = try await repository.fetchActivityCount(for: .last7Days)
        
        var entries = generateMockLeaderboard(userCO2Saved: userCO2Saved, userActivities: userActivities, userStreak: userStreak)
        
        entries.sort { $0.totalCO2Saved > $1.totalCO2Saved }
        
        for index in entries.indices {
            entries[index].rank = index + 1
        }
        
        return Array(entries.prefix(limit))
    }
    
    func getWeeklyLeaderboard() async throws -> [LeaderboardEntry] {
        let weeklyTrend = try await repository.fetchWeeklyTrend()
        let weeklyCO2 = weeklyTrend.reduce(0.0) { $0 + $1.totalCO2 }
        
        var entries = generateMockLeaderboard(userCO2Saved: weeklyCO2, userActivities: 0, userStreak: 0)
        
        entries.sort { $0.totalCO2Saved > $1.totalCO2Saved }
        
        for index in entries.indices {
            entries[index].rank = index + 1
        }
        
        return Array(entries.prefix(10))
    }
    
    private func calculateRankFromCO2(_ co2Saved: Double) -> Int {
        let thresholds: [Double] = [1000, 500, 200, 100, 50, 20, 10, 5, 1, 0]
        let ranks = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        for (index, threshold) in thresholds.enumerated() {
            if co2Saved >= threshold {
                return ranks[index]
            }
        }
        return 10
    }
    
    private func generateMockLeaderboard(userCO2Saved: Double, userActivities: Int, userStreak: Int) -> [LeaderboardEntry] {
        let mockNames = [
            "EcoWarrior", "GreenMachine", "PlanetSaver", "CarbonCutter", "EcoHero",
            "NatureLover", "SustainableSam", "EcoEmma", "GreenGreg", "NatureNick"
        ]
        
        let avatars = ["leaf.fill", "tree.fill", "drop.fill", "wind", "sun.max.fill"]
        
        return mockNames.enumerated().map { index, name in
            let isCurrentUser = index == 5
            return LeaderboardEntry(
                id: isCurrentUser ? "current_user" : "user_\(index)",
                displayName: isCurrentUser ? "You" : name,
                avatarName: avatars[index % avatars.count],
                totalCO2Saved: isCurrentUser ? userCO2Saved : Double.random(in: 1...500),
                totalActivities: isCurrentUser ? userActivities : Int.random(in: 1...100),
                currentStreak: isCurrentUser ? userStreak : Int.random(in: 0...30),
                rank: 0
            )
        }
    }
}
