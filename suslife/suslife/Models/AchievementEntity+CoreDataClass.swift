//
//  AchievementEntity+CoreDataClass.swift
//  suslife
//
//  Achievement Entity - CoreData entity for achievements
//

import Foundation
import CoreData

@objc(AchievementEntity)
public class AchievementEntity: NSManagedObject {
    
    static func create(
        in context: NSManagedObjectContext,
        achievementId: String,
        title: String,
        desc: String,
        iconName: String,
        category: String,
        xpReward: Int
    ) -> AchievementEntity {
        let entity = AchievementEntity(context: context)
        entity.achievementId = achievementId
        entity.title = title
        entity.desc = desc
        entity.iconName = iconName
        entity.category = category
        entity.xpReward = Int32(xpReward)
        entity.isUnlocked = false
        entity.progress = 0.0
        return entity
    }
    
    func toAchievement() -> Achievement {
        let requirement = AchievementRequirementMapper.mapFromId(achievementId)
        let categoryEnum = AchievementCategory(rawValue: category) ?? .logging
        
        let achievement = Achievement(
            id: achievementId,
            title: title,
            description: desc,
            iconName: iconName,
            category: categoryEnum,
            requirement: requirement,
            xpReward: Int(xpReward)
        )
        
        achievement.isUnlocked = isUnlocked
        achievement.progress = progress
        achievement.unlockedDate = unlockedDate
        
        return achievement
    }
}

enum AchievementRequirementMapper {
    static func mapFromId(_ id: String) -> AchievementRequirement {
        switch id {
        case "first_log":
            return .totalActivities(count: 1)
        case "ten_activities":
            return .totalActivities(count: 10)
        case "fifty_activities":
            return .totalActivities(count: 50)
        case "hundred_activities":
            return .totalActivities(count: 100)
        case "streak_3":
            return .streakDays(days: 3)
        case "streak_7":
            return .streakDays(days: 7)
        case "streak_30":
            return .streakDays(days: 30)
        case "co2_10kg":
            return .totalCO2Saved(kg: 10)
        case "co2_50kg":
            return .totalCO2Saved(kg: 50)
        case "co2_100kg":
            return .totalCO2Saved(kg: 100)
        case "week_full":
            return .weeklyActivities(week: 1, count: 7)
        case "consecutive_5":
            return .consecutiveDays(days: 5)
        default:
            return .totalActivities(count: 1)
        }
    }
}
