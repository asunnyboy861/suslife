//
//  CoreDataStack.swift
//  suslife
//
//  CoreData Stack - Manages CoreData stack with async/await support and CloudKit sync
//

import Foundation
import CoreData
import CloudKit

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        print("💾 [CoreDataStack] Initializing persistentContainer...")
        let container = NSPersistentContainer(name: "suslife")
        print("💾 [CoreDataStack] Container created with name: suslife")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No store descriptions")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        let cloudKitEnabled = UserDefaults.standard.bool(forKey: "cloudKitSyncEnabled")
        print("💾 [CoreDataStack] CloudKit sync enabled: \(cloudKitEnabled)")
        if cloudKitEnabled {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.zzoutuo.suslife"
            )
        }
        
        print("💾 [CoreDataStack] Loading persistent stores...")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ [CoreDataStack] ERROR: CoreData loading failed: \(error.localizedDescription)")
                fatalError("CoreData loading failed: \(error.localizedDescription)")
            }
            print("✅ [CoreDataStack] Persistent store loaded successfully: \(description)")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        print("✅ [CoreDataStack] View context configured")
        
        return container
    }()
    
    lazy var cloudKitContainer: NSPersistentCloudKitContainer? = {
        guard UserDefaults.standard.bool(forKey: "cloudKitSyncEnabled") else { return nil }
        
        let container = NSPersistentCloudKitContainer(name: "suslife")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No store descriptions")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.zzoutuo.suslife"
        )
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CloudKit container loading failed: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Contexts
    
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        return context
    }
    
    // MARK: - Save
    
    func save() throws {
        let context = mainContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    func saveWithRetry(maxAttempts: Int = 3) throws {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                try save()
                return
            } catch {
                lastError = error
                print("Save attempt \(attempt) failed: \(error.localizedDescription)")
                
                if attempt < maxAttempts {
                    mainContext.rollback()
                    Thread.sleep(forTimeInterval: Double(attempt) * 0.1)
                }
            }
        }
        
        throw lastError ?? CoreDataError.saveFailed
    }
    
    // MARK: - Testing Support
    
    static func createInMemoryStack() -> CoreDataStack {
        let stack = CoreDataStack()
        
        let container = NSPersistentContainer(name: "suslife")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No store descriptions")
        }
        
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("In-memory store failed: \(error.localizedDescription)")
            }
        }
        
        stack.persistentContainer = container
        return stack
    }
}

// MARK: - Errors

enum CoreDataError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed: return "Failed to save data"
        case .fetchFailed: return "Failed to fetch data"
        case .deleteFailed: return "Failed to delete data"
        }
    }
}
