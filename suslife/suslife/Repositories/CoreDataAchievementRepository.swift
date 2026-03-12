//
//  AchievementRepository.swift
//  suslife
//
//  Achievement Repository - Manages achievement persistence
//

import Foundation
import CoreData

protocol AchievementRepositoryProtocol {
    func fetchAll() async throws -> [Achievement]
    func save(_ achievement: Achievement) async throws
    func initializeDefaultAchievements() async throws
    func getTotalXP() async throws -> Int
    func saveTotalXP(_ xp: Int) async throws
}

final class CoreDataAchievementRepository: AchievementRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchAll() async throws -> [Achievement] {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "achievementId", ascending: true)]
            
            let entities = try context.fetch(request)
            
            if entities.isEmpty {
                return Achievement.allAchievements
            }
            
            return entities.map { $0.toAchievement() }
        }
    }
    
    func save(_ achievement: Achievement) async throws {
        let context = coreDataStack.mainContext
        
        try await context.perform {
            let request: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
            request.predicate = NSPredicate(format: "achievementId == %@", achievement.id)
            
            if let entity = try context.fetch(request).first {
                entity.isUnlocked = achievement.isUnlocked
                entity.progress = achievement.progress
                entity.unlockedDate = achievement.unlockedDate
            } else {
                let entity = AchievementEntity.create(
                    in: context,
                    achievementId: achievement.id,
                    title: achievement.title,
                    desc: achievement.description,
                    iconName: achievement.iconName,
                    category: achievement.category.rawValue,
                    xpReward: achievement.xpReward
                )
                entity.isUnlocked = achievement.isUnlocked
                entity.progress = achievement.progress
                entity.unlockedDate = achievement.unlockedDate
            }
            
            try context.save()
        }
    }
    
    func initializeDefaultAchievements() async throws {
        let context = coreDataStack.mainContext
        
        try await context.perform {
            let request: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
            let existingCount = try context.count(for: request)
            
            guard existingCount == 0 else { return }
            
            for achievement in Achievement.allAchievements {
                let entity = AchievementEntity.create(
                    in: context,
                    achievementId: achievement.id,
                    title: achievement.title,
                    desc: achievement.description,
                    iconName: achievement.iconName,
                    category: achievement.category.rawValue,
                    xpReward: achievement.xpReward
                )
                entity.isUnlocked = false
                entity.progress = 0.0
            }
            
            try context.save()
        }
    }
    
    func getTotalXP() async throws -> Int {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isUnlocked == YES")
            
            let entities = try context.fetch(request)
            return entities.reduce(0) { $0 + Int($1.xpReward) }
        }
    }
    
    func saveTotalXP(_ xp: Int) async throws {
        UserDefaults.standard.set(xp, forKey: "total_xp")
    }
    
    func migrateFromUserDefaults() async throws {
        let context = coreDataStack.mainContext
        
        try await context.perform {
            let request: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
            let existingCount = try context.count(for: request)
            
            guard existingCount == 0 else { return }
            
            for achievement in Achievement.allAchievements {
                let entity = AchievementEntity.create(
                    in: context,
                    achievementId: achievement.id,
                    title: achievement.title,
                    desc: achievement.description,
                    iconName: achievement.iconName,
                    category: achievement.category.rawValue,
                    xpReward: achievement.xpReward
                )
                
                entity.isUnlocked = UserDefaults.standard.bool(forKey: "achievement_\(achievement.id)_unlocked")
                entity.progress = UserDefaults.standard.double(forKey: "achievement_\(achievement.id)_progress")
                entity.unlockedDate = UserDefaults.standard.object(forKey: "achievement_\(achievement.id)_date") as? Date
            }
            
            try context.save()
        }
    }
}
