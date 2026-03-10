//
//  UserProfile+CoreDataProperties.swift
//  suslife
//
//  User Profile Properties
//

import Foundation
import CoreData

public extension UserProfile {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<UserProfile> {
        NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var dailyCO2Goal: Double
    @NSManaged public var weeklyStreak: Int32
    @NSManaged public var totalActivitiesLogged: Int32
    @NSManaged public var joinDate: Date
    @NSManaged public var cloudKitSyncEnabled: Bool
    @NSManaged public var unitsSystem: String
}

// MARK: - Identifiable
extension UserProfile: Identifiable {
}

// MARK: - Display Helpers
extension UserProfile {
    
    /// Formatted daily goal
    var dailyGoalFormatted: String {
        String(format: "%.0f lbs CO₂", dailyCO2Goal)
    }
    
    /// Streak display
    var streakDisplay: String {
        "\(weeklyStreak) week\(weeklyStreak == 1 ? "" : "s")"
    }
}
