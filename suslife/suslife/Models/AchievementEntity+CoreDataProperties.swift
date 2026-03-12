//
//  AchievementEntity+CoreDataProperties.swift
//  suslife
//
//  Achievement Entity Properties - CoreData properties for achievements
//

import Foundation
import CoreData

extension AchievementEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AchievementEntity> {
        return NSFetchRequest<AchievementEntity>(entityName: "AchievementEntity")
    }
    
    @NSManaged public var achievementId: String
    @NSManaged public var title: String
    @NSManaged public var desc: String
    @NSManaged public var iconName: String
    @NSManaged public var category: String
    @NSManaged public var xpReward: Int32
    @NSManaged public var isUnlocked: Bool
    @NSManaged public var progress: Double
    @NSManaged public var unlockedDate: Date?
}

extension AchievementEntity: Identifiable {}
