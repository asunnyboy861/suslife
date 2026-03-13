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
    
    @NSManaged var id: UUID
    @NSManaged var dailyCO2Goal: Double
    @NSManaged var weeklyStreak: Int32
    @NSManaged var totalActivitiesLogged: Int32
    @NSManaged var joinDate: Date
    @NSManaged var cloudKitSyncEnabled: Bool
    @NSManaged var unitsSystem: String
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
