//
//  UserProfile+CoreDataClass.swift
//  suslife
//
//  User Profile Model - Stores user settings and statistics
//

import Foundation
import CoreData

@objc(UserProfile)
public class UserProfile: NSManagedObject {
    
    /// Get or create singleton user profile
    static func getCurrent(in context: NSManagedObjectContext) -> UserProfile {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        // Create default profile
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.dailyCO2Goal = 28.0 // lbs - average US daily footprint
        profile.weeklyStreak = 0
        profile.totalActivitiesLogged = 0
        profile.joinDate = Date()
        profile.cloudKitSyncEnabled = false
        profile.unitsSystem = "imperial"
        
        return profile
    }
}
