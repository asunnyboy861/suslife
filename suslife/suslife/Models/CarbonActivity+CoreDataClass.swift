//
//  CarbonActivity+CoreDataClass.swift
//  suslife
//
//  Carbon Activity Model - Represents a single carbon-emitting activity
//

import Foundation
import CoreData

@objc(CarbonActivity)
public class CarbonActivity: NSManagedObject {
    
    /// Create a new carbon activity with validation
    static func create(
        in context: NSManagedObjectContext,
        category: String,
        activityType: String,
        value: Double,
        unit: String,
        notes: String? = nil,
        date: Date = Date()
    ) -> CarbonActivity {
        let activity = CarbonActivity(context: context)
        activity.id = UUID()
        activity.category = category
        activity.activityType = activityType
        activity.value = value
        activity.unit = unit
        activity.notes = notes
        activity.date = date
        
        // Calculate CO2 using current emission factors (real-time calculation)
        activity.co2Emission = CO2Calculator.calculate(
            category: category,
            activityType: activityType,
            value: value
        )
        
        // Track emission factor version
        activity.emissionFactorVersion = EmissionFactorsVersion.current
        
        return activity
    }
    
    /// Real-time CO2 calculation using latest emission factors
    var currentCO2Emission: Double {
        CO2Calculator.calculate(
            category: category,
            activityType: activityType,
            value: value
        )
    }
}
