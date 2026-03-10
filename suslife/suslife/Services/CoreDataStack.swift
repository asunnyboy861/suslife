//
//  CoreDataStack.swift
//  suslife
//
//  CoreData Stack - Manages CoreData stack with async/await support
//

import Foundation
import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "suslife")
        
        // Enable history tracking for CloudKit sync (future)
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No store descriptions")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreData loading failed: \(error.localizedDescription)")
            }
        }
        
        // Enable automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Contexts
    
    /// Main context for UI operations
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /// Create a new background context for heavy operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        return context
    }
    
    // MARK: - Save
    
    /// Save main context if there are changes
    func save() throws {
        let context = mainContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// Save with error recovery
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
    
    /// Create in-memory stack for unit tests
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
