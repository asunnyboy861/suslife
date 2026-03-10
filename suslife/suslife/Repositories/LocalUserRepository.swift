//
//  LocalUserRepository.swift
//  suslife
//
//  Local User Repository Implementation
//

import Foundation
import CoreData

final class LocalUserRepository: UserRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func getUserProfile() async throws -> UserProfile {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            UserProfile.getCurrent(in: context)
        }
    }
    
    func updateStreak(_ streak: Int32) async throws {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let profile = UserProfile.getCurrent(in: context)
            profile.weeklyStreak = streak
            try? context.save()
        }
    }
    
    func incrementActivityCount() async throws {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let profile = UserProfile.getCurrent(in: context)
            profile.totalActivitiesLogged += 1
            try? context.save()
        }
    }
    
    func save() async throws {
        try coreDataStack.save()
    }
}
