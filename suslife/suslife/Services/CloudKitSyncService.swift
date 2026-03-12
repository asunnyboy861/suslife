//
//  CloudKitSyncService.swift
//  suslife
//
//  CloudKit Sync Service - Manages iCloud synchronization
//

import Foundation
import CloudKit
import CoreData

@MainActor
final class CloudKitSyncService: ObservableObject {
    static let shared = CloudKitSyncService()
    
    @Published var isSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSyncEnabled, forKey: "cloudKitSyncEnabled")
        }
    }
    
    @Published var syncStatus: SyncStatus = .notConfigured
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    
    private let containerIdentifier = "iCloud.com.zzoutuo.suslife"
    private let container: CKContainer
    
    private init() {
        self.container = CKContainer(identifier: containerIdentifier)
        self.isSyncEnabled = UserDefaults.standard.bool(forKey: "cloudKitSyncEnabled")
        self.lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }
    
    func checkAccountStatus() async -> CKAccountStatus {
        return await withCheckedContinuation { continuation in
            container.accountStatus { status, error in
                if let error = error {
                    print("Account status error: \(error.localizedDescription)")
                }
                continuation.resume(returning: status)
            }
        }
    }
    
    func enableSync() async -> Bool {
        let accountStatus = await checkAccountStatus()
        
        guard accountStatus == .available else {
            syncStatus = .noAccount
            errorMessage = "Please sign in to iCloud to enable sync"
            return false
        }
        
        isSyncEnabled = true
        syncStatus = .enabled
        
        await syncNow()
        
        return true
    }
    
    func disableSync() {
        isSyncEnabled = false
        syncStatus = .disabled
        UserDefaults.standard.set(false, forKey: "cloudKitSyncEnabled")
    }
    
    func syncNow() async {
        guard isSyncEnabled else { return }
        
        syncStatus = .syncing
        
        let accountStatus = await checkAccountStatus()
        
        guard accountStatus == .available else {
            syncStatus = .noAccount
            errorMessage = "iCloud account not available"
            return
        }
        
        do {
            let context = CoreDataStack.shared.mainContext
            
            try await context.perform {
                try context.save()
            }
            
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
            syncStatus = .synced
            errorMessage = nil
            
        } catch {
            syncStatus = .error
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchCloudRecordCount() async -> Int {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CarbonActivity", predicate: predicate)
        
        do {
            let (results, _) = try await container.privateCloudDatabase.records(matching: query)
            return results.count
        } catch {
            print("Fetch record count error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func deleteAllCloudData() async throws {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CarbonActivity", predicate: predicate)
        
        var recordIDsToDelete: [CKRecord.ID] = []
        
        var cursor: CKQueryOperation.Cursor?
        repeat {
            let (results, nextCursor) = try await container.privateCloudDatabase.records(matching: query)
            
            for (recordID, _) in results {
                recordIDsToDelete.append(recordID)
            }
            
            cursor = nextCursor
        } while cursor != nil
        
        for recordID in recordIDsToDelete {
            try await container.privateCloudDatabase.deleteRecord(withID: recordID)
        }
    }
    
    func getSyncStatusDescription() -> String {
        switch syncStatus {
        case .notConfigured:
            return "Not configured"
        case .disabled:
            return "Sync disabled"
        case .enabled:
            return "Sync enabled"
        case .syncing:
            return "Syncing..."
        case .synced:
            if let date = lastSyncDate {
                let formatter = RelativeDateTimeFormatter()
                return "Last synced \(formatter.localizedString(for: date, relativeTo: Date()))"
            }
            return "Synced"
        case .error:
            return "Sync error: \(errorMessage ?? "Unknown")"
        case .noAccount:
            return "No iCloud account"
        }
    }
}

enum SyncStatus: Equatable {
    case notConfigured
    case disabled
    case enabled
    case syncing
    case synced
    case error
    case noAccount
}
