//
//  CarbonActivity+CoreDataProperties.swift
//  suslife
//
//  Carbon Activity Properties
//

import Foundation
import CoreData

public extension CarbonActivity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CarbonActivity> {
        NSFetchRequest<CarbonActivity>(entityName: "CarbonActivity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var category: String
    @NSManaged public var activityType: String
    @NSManaged public var value: Double
    @NSManaged public var unit: String
    @NSManaged public var co2Emission: Double
    @NSManaged public var date: Date
    @NSManaged public var notes: String?
    @NSManaged public var emissionFactorVersion: String
}

// MARK: - Identifiable
extension CarbonActivity: Identifiable {
}

// MARK: - Display Helpers
extension CarbonActivity {
    
    /// Formatted CO2 emission in lbs
    var co2EmissionFormatted: String {
        String(format: "%.1f lbs CO₂", co2Emission)
    }
    
    /// Formatted value with unit
    var valueFormatted: String {
        String(format: "%.1f %@", value, unit)
    }
    
    /// Category icon
    var categoryIcon: String {
        switch category {
        case "transport": return "car.fill"
        case "food": return "fork.knife"
        case "shopping": return "bag.fill"
        case "energy": return "bolt.fill"
        default: return "leaf.fill"
        }
    }
    
    /// Activity type display name
    var activityTypeDisplayName: String {
        activityType.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
