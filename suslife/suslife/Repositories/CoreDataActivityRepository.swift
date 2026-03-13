//
//  CoreDataActivityRepository.swift
//  suslife
//
//  CoreData Implementation of Activity Repository
//

import Foundation
import CoreData

final class CoreDataActivityRepository: ActivityRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Fetch Operations
    
    func fetchTodayActivities() async throws -> [CarbonActivity] {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            
            // Start of today (midnight)
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            
            request.predicate = NSPredicate(format: "date >= %@", startOfDay as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            return try context.fetch(request)
        }
    }
    
    func fetchActivities(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [CarbonActivity] {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try context.fetch(request)
        }
    }
    
    func fetchTodayTotalCO2() async throws -> Double {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            
            request.predicate = NSPredicate(format: "date >= %@", startOfDay as NSDate)
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = ["co2Emission"]
            
            let results = try context.fetch(request) as? [[String: Double]] ?? []
            return results.flatMap { $0.values }.reduce(0, +)
        }
    }
    
    func fetchWeeklyTrend() async throws -> [DailyTotal] {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -6, to: Date())!
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: Date())!
            
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endOfDay as NSDate)
            
            let activities = try context.fetch(request)
            
            // Group by date
            let grouped = Dictionary(grouping: activities) { activity in
                calendar.startOfDay(for: activity.date)
            }
            
            // Convert to DailyTotal
            return grouped.map { date, activities in
                DailyTotal(
                    date: date,
                    totalCO2: activities.reduce(0) { $0 + $1.co2Emission },
                    activityCount: activities.count
                )
            }.sorted { $0.date < $1.date }
        }
    }
    
    // MARK: - Save Operations
    
    func save(_ input: ActivityInput) async throws -> CarbonActivity {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let activity = CarbonActivity.create(
                in: context,
                category: input.category,
                activityType: input.activityType,
                value: input.value,
                unit: input.unit,
                notes: input.notes,
                date: input.date
            )
            
            try context.save()
            return activity
        }
    }
    
    func saveAll(_ inputs: [ActivityInput]) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        return try await context.perform {
            for input in inputs {
                _ = CarbonActivity.create(
                    in: context,
                    category: input.category,
                    activityType: input.activityType,
                    value: input.value,
                    unit: input.unit,
                    notes: input.notes,
                    date: input.date
                )
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    // MARK: - Delete Operations
    
    func delete(id: UUID) async throws {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
            
            if let activity = try context.fetch(request).first {
                context.delete(activity)
                try context.save()
            }
        }
    }
    
    func deleteAll() async throws {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = CarbonActivity.fetchRequest()
            let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(batchDelete)
            try context.save()
        }
    }
    
    // MARK: - Analytics
    
    func calculateTotalCO2Saved() async throws -> Double {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = ["co2Emission"]
            
            let results = try context.fetch(request) as? [[String: Double]] ?? []
            let totalCO2 = results.flatMap { $0.values }.reduce(0, +)
            
            // Calculate saved CO2 vs average US baseline
            // Average US daily footprint: 28 lbs
            let days = self.calculateDaysSinceFirstActivity(activities: try context.fetch(CarbonActivity.fetchRequest()))
            let baseline = Double(days) * 28.0
            
            return max(0, baseline - totalCO2)
        }
    }
    
    // MARK: - Additional Methods for Achievements
    
    /// Get total number of activities logged
    func fetchTotalActivities() async throws -> Int {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            return try context.count(for: request)
        }
    }
    
    /// Get monthly trend data (last 30 days)
    func fetchMonthlyTrend() async throws -> [DailyTotal] {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -29, to: Date())!
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: Date())!
            
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endOfDay as NSDate)
            
            let activities = try context.fetch(request)
            
            // Group by date
            let grouped = Dictionary(grouping: activities) { activity in
                calendar.startOfDay(for: activity.date)
            }
            
            // Convert to DailyTotal
            return grouped.map { date, activities in
                DailyTotal(
                    date: date,
                    totalCO2: activities.reduce(0) { $0 + $1.co2Emission },
                    activityCount: activities.count
                )
            }.sorted { $0.date < $1.date }
        }
    }
    
    // MARK: - Helpers
    
    private func calculateDaysSinceFirstActivity(activities: [CarbonActivity]) -> Int {
        guard let firstDate = activities.min(by: { $0.date < $1.date })?.date else {
            return 0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstDate, to: Date())
        return max(1, components.day ?? 1)
    }
    
    func fetchActivityCount(for dateRange: DateRange) async throws -> Int {
        let calendar = Calendar.current
        let (start, end) = getDateRange(for: dateRange, calendar: calendar)
        
        let activities = try await fetchActivities(from: start, to: end)
        return activities.count
    }
    
    /// Calculates the current streak of consecutive days with logged activities.
    /// 
    /// This method counts backwards from today, checking each day for at least one activity.
    /// The streak breaks when a day with no activities is encountered.
    /// 
    /// - Returns: The number of consecutive days (including today) with at least one activity
    /// - Throws: CoreData errors if fetch fails
    /// 
    /// Example:
    /// - User logged activities today, yesterday, and 2 days ago: returns 3
    /// - User logged activities today and 2 days ago (skipped yesterday): returns 1
    /// - User has no activities: returns 0
    func calculateCurrentStreak() async throws -> Int {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let calendar = Calendar.current
            var streak = 0
            var currentDate = Date()
            
            // Check up to 365 days back (reasonable limit)
            for _ in 0..<365 {
                let startOfDay = calendar.startOfDay(for: currentDate)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "date >= %@ AND date < %@",
                    startOfDay as NSDate,
                    endOfDay as NSDate
                )
                request.fetchLimit = 1  // Only need to know if any exist
                
                let count = try context.count(for: request)
                
                if count > 0 {
                    streak += 1
                    // Move to previous day
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    // Streak broken
                    break
                }
            }
            
            return streak
        }
    }
    
    // MARK: - Private Helpers
    
    private func getDateRange(for dateRange: DateRange, calendar: Calendar) -> (start: Date, end: Date) {
        let now = Date()
        
        switch dateRange {
        case .today:
            return (calendar.startOfDay(for: now), now)
        case .last7Days:
            return (calendar.date(byAdding: .day, value: -6, to: now)!, now)
        case .last30Days:
            return (calendar.date(byAdding: .day, value: -29, to: now)!, now)
        case .custom(let start, let end):
            return (start, end)
        }
    }
}
