//
//  LocalUserRepository.swift
//  suslife
//
//  Local User Repository Implementation
//

import Foundation
import CoreData

/// Local CoreData implementation of UserRepositoryProtocol
final class LocalUserRepository: UserRepositoryProtocol {
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - UserRepositoryProtocol Methods
    
    func getUserProfile() async throws -> UserProfile {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            UserProfile.getCurrent(in: context)
        }
    }
    
    func createUserProfile(settings: UserProfileSettings) async throws -> UserProfile {
        print("💾 [LocalUserRepository] createUserProfile called")
        let context = coreDataStack.mainContext
        print("💾 [LocalUserRepository] Got main context")
        
        return try await context.perform {
            print("💾 [LocalUserRepository] Inside context.perform")
            
            // Use getCurrent to ensure singleton pattern
            print("💾 [LocalUserRepository] Calling UserProfile.getCurrent...")
            let profile = UserProfile.getCurrent(in: context)
            print("💾 [LocalUserRepository] Got profile, id: \(profile.id)")
            print("💾 [LocalUserRepository] Profile exists: \(profile.objectID.isTemporaryID)")
            
            // Update profile with new settings
            print("💾 [LocalUserRepository] Updating profile settings...")
            profile.dailyCO2Goal = settings.dailyCO2Goal
            profile.cloudKitSyncEnabled = settings.healthKitEnabled
            profile.unitsSystem = settings.unitsSystem
            print("💾 [LocalUserRepository] Profile updated")
            
            print("💾 [LocalUserRepository] Saving context...")
            try context.save()
            print("💾 [LocalUserRepository] Context saved successfully")
            
            return profile
        }
    }
    
    func updateDailyGoal(_ goal: Double) async throws {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let profile = UserProfile.getCurrent(in: context)
            profile.dailyCO2Goal = goal
            try context.save()
        }
    }
    
    func updateStreak(_ streak: Int32) async throws {
        let context = coreDataStack.mainContext
        
        await context.perform {
            let profile = UserProfile.getCurrent(in: context)
            profile.weeklyStreak = streak
            try? context.save()
        }
    }
    
    func incrementActivityCount() async throws {
        let context = coreDataStack.mainContext
        
        await context.perform {
            let profile = UserProfile.getCurrent(in: context)
            profile.totalActivitiesLogged += 1
            try? context.save()
        }
    }
    
    func save() async throws {
        try coreDataStack.save()
    }
}
