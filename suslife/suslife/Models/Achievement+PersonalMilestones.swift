//
//  Achievement+PersonalMilestones.swift
//  suslife
//
//  Achievement Extension - Personal milestone achievements
//

import Foundation

extension Achievement {
    // MARK: - Personal Milestone Achievements
    
    /// Personal milestone achievements using existing requirement types
    static let personalMilestones: [Achievement] = [
        Achievement(
            id: "first_100_lbs",
            title: "First 100 lbs",
            description: "Reduce your first 100 lbs of CO₂",
            iconName: "leaf.fill",
            category: .environmental,
            requirement: .totalCO2Saved(kg: 45.36),  // 100 lbs = 45.36 kg
            xpReward: 50
        ),
        Achievement(
            id: "eco_warrior_500",
            title: "Eco Warrior",
            description: "Reduce 500 lbs of CO₂",
            iconName: "star.fill",
            category: .environmental,
            requirement: .totalCO2Saved(kg: 226.8),  // 500 lbs
            xpReward: 150
        ),
        Achievement(
            id: "planet_saver_1000",
            title: "Planet Saver",
            description: "Reduce 1000 lbs of CO₂",
            iconName: "earth.americas.fill",
            category: .environmental,
            requirement: .totalCO2Saved(kg: 453.59),  // 1000 lbs
            xpReward: 300
        ),
        Achievement(
            id: "streak_7_personal",
            title: "Week Warrior",
            description: "Maintain a 7-day logging streak",
            iconName: "calendar.badge.checkmark",
            category: .streak,
            requirement: .streakDays(days: 7),
            xpReward: 100
        ),
        Achievement(
            id: "streak_30_personal",
            title: "Month Master",
            description: "Maintain a 30-day logging streak",
            iconName: "calendar",
            category: .streak,
            requirement: .streakDays(days: 30),
            xpReward: 300
        ),
        Achievement(
            id: "century_club",
            title: "Century Club",
            description: "Log 100 sustainable activities",
            iconName: "checkmark.seal.fill",
            category: .logging,
            requirement: .totalActivities(count: 100),
            xpReward: 200
        )
    ]
}

// MARK: - AchievementService Extension

extension AchievementService {
    /// Check and unlock personal milestone achievements
    func checkPersonalMilestones() async {
        // Personal milestones are already included in the main checkAchievements() method
        // This method is kept for future extensibility
        await checkAchievements()
    }
}
