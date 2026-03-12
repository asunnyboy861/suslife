//
//  Achievement.swift
//  suslife
//
//  Achievement Model - Defines achievement types and progress
//

import Foundation

final class Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let requirement: AchievementRequirement
    let xpReward: Int
    
    var isUnlocked: Bool = false
    var progress: Double = 0.0
    var unlockedDate: Date? = nil
    
    init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        requirement: AchievementRequirement,
        xpReward: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.xpReward = xpReward
    }
    
    init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        requirement: AchievementRequirement,
        xpReward: Int,
        isUnlocked: Bool,
        progress: Double,
        unlockedDate: Date?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.xpReward = xpReward
        self.isUnlocked = isUnlocked
        self.progress = progress
        self.unlockedDate = unlockedDate
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case logging = "Logging"
    case streak = "Streak"
    case environmental = "Environmental"
    case social = "Social"
    
    var displayName: String { rawValue }
}

enum AchievementRequirement: Codable {
    case totalActivities(count: Int)
    case streakDays(days: Int)
    case totalCO2Saved(kg: Double)
    case weeklyActivities(week: Int, count: Int)
    case categoryMilestone(category: String, count: Int)
    case consecutiveDays(days: Int)
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_log",
            title: "First Step",
            description: "Log your first sustainable activity",
            iconName: "leaf.fill",
            category: .logging,
            requirement: .totalActivities(count: 1),
            xpReward: 10
        ),
        Achievement(
            id: "ten_activities",
            title: "Eco Starter",
            description: "Log 10 sustainable activities",
            iconName: "star.fill",
            category: .logging,
            requirement: .totalActivities(count: 10),
            xpReward: 50
        ),
        Achievement(
            id: "fifty_activities",
            title: "Eco Enthusiast",
            description: "Log 50 sustainable activities",
            iconName: "sparkles",
            category: .logging,
            requirement: .totalActivities(count: 50),
            xpReward: 100
        ),
        Achievement(
            id: "hundred_activities",
            title: "Eco Champion",
            description: "Log 100 sustainable activities",
            iconName: "trophy.fill",
            category: .logging,
            requirement: .totalActivities(count: 100),
            xpReward: 250
        ),
        Achievement(
            id: "streak_3",
            title: "Getting Started",
            description: "Maintain a 3-day logging streak",
            iconName: "flame.fill",
            category: .streak,
            requirement: .streakDays(days: 3),
            xpReward: 30
        ),
        Achievement(
            id: "streak_7",
            title: "Week Warrior",
            description: "Maintain a 7-day logging streak",
            iconName: "flame.circle.fill",
            category: .streak,
            requirement: .streakDays(days: 7),
            xpReward: 75
        ),
        Achievement(
            id: "streak_30",
            title: "Monthly Master",
            description: "Maintain a 30-day logging streak",
            iconName: "crown.fill",
            category: .streak,
            requirement: .streakDays(days: 30),
            xpReward: 300
        ),
        Achievement(
            id: "co2_10kg",
            title: "Carbon Cutter",
            description: "Save 10 kg of CO2 emissions",
            iconName: "aqi.medium",
            category: .environmental,
            requirement: .totalCO2Saved(kg: 10),
            xpReward: 100
        ),
        Achievement(
            id: "co2_50kg",
            title: "Planet Protector",
            description: "Save 50 kg of CO2 emissions",
            iconName: "globe.americas.fill",
            category: .environmental,
            requirement: .totalCO2Saved(kg: 50),
            xpReward: 250
        ),
        Achievement(
            id: "co2_100kg",
            title: "Climate Hero",
            description: "Save 100 kg of CO2 emissions",
            iconName: "earthmoji",
            category: .environmental,
            requirement: .totalCO2Saved(kg: 100),
            xpReward: 500
        ),
        Achievement(
            id: "week_full",
            title: "Week Winner",
            description: "Log activities all 7 days of a week",
            iconName: "calendar.badge.checkmark",
            category: .streak,
            requirement: .weeklyActivities(week: 1, count: 7),
            xpReward: 100
        ),
        Achievement(
            id: "consecutive_5",
            title: "On a Roll",
            description: "Log activities for 5 consecutive days",
            iconName: "bolt.fill",
            category: .streak,
            requirement: .consecutiveDays(days: 5),
            xpReward: 50
        )
    ]
}
