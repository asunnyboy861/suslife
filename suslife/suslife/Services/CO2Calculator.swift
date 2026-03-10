//
//  CO2Calculator.swift
//  suslife
//
//  CO2 Calculation Engine - US-specific emission factors (Imperial units)
//

import Foundation

/// Calculate carbon emissions based on US-specific emission factors
/// Data Sources: EPA, USDA, EIA (2024)
struct CO2Calculator {
    
    // MARK: - Emission Factors (US-Specific, Imperial Units)
    
    /// Transport emission factors (lbs CO2 per mile)
    enum Transport {
        static let walking: Double = 0.0
        static let bicycle: Double = 0.0
        static let bus: Double = 0.055       // Average city bus
        static let train: Double = 0.025     // Amtrak average
        static let car: Double = 0.13        // Average US passenger vehicle
        static let flight: Double = 0.159    // Domestic flight average
        static let ev: Double = 0.065        // Electric vehicle (US grid mix)
    }
    
    /// Food emission factors (lbs CO2 per portion)
    enum Food {
        static let vegan: Double = 1.1       // Plant-based meal
        static let vegetarian: Double = 2.2  // Vegetarian meal
        static let chicken: Double = 5.1     // Chicken dish
        static let pork: Double = 7.7        // Pork dish
        static let beef: Double = 13.2       // Beef dish
        static let fish: Double = 5.1        // Fish dish
        static let dairy: Double = 3.3       // Dairy product
    }
    
    /// Shopping emission factors (lbs CO2 per item)
    enum Shopping {
        static let clothing: Double = 22.0      // Average garment
        static let electronics: Double = 110.0  // Small electronic device
        static let furniture: Double = 66.0     // Average furniture item
        static let books: Double = 3.3
        static let household: Double = 11.0     // Household items
    }
    
    /// Energy emission factors (lbs CO2 per kWh)
    enum Energy {
        static let electricity: Double = 1.88   // EPA eGRID 2024 (US average)
        static let naturalGas: Double = 11.7    // EPA emission factor
        static let propane: Double = 10.4
        static let solar: Double = 0.0
        static let wind: Double = 0.0
    }
    
    // MARK: - Public API
    
    /// Calculate CO2 emission
    /// - Parameters:
    ///   - category: Activity category (transport, food, shopping, energy)
    ///   - activityType: Specific activity type (car, beef, clothing, etc.)
    ///   - value: Numeric value in imperial units (miles, portions, items, kWh)
    /// - Returns: CO2 emission in pounds (lbs)
    static func calculate(
        category: String,
        activityType: String,
        value: Double
    ) -> Double {
        guard value >= 0 else { return 0 }
        
        let factor = getEmissionFactor(category: category, activityType: activityType)
        return value * factor
    }
    
    // MARK: - Private Helpers
    
    private static func getEmissionFactor(
        category: String,
        activityType: String
    ) -> Double {
        switch category {
        case "transport":
            return getTransportFactor(type: activityType)
        case "food":
            return getFoodFactor(type: activityType)
        case "shopping":
            return getShoppingFactor(type: activityType)
        case "energy":
            return getEnergyFactor(type: activityType)
        default:
            return 0.0
        }
    }
    
    private static func getTransportFactor(type: String) -> Double {
        switch type {
        case "walking": return Transport.walking
        case "bicycle": return Transport.bicycle
        case "bus": return Transport.bus
        case "train": return Transport.train
        case "car": return Transport.car
        case "flight": return Transport.flight
        case "ev": return Transport.ev
        default: return Transport.car // Fallback
        }
    }
    
    private static func getFoodFactor(type: String) -> Double {
        switch type {
        case "vegan": return Food.vegan
        case "vegetarian": return Food.vegetarian
        case "chicken": return Food.chicken
        case "pork": return Food.pork
        case "beef": return Food.beef
        case "fish": return Food.fish
        case "dairy": return Food.dairy
        default: return Food.vegetarian // Fallback
        }
    }
    
    private static func getShoppingFactor(type: String) -> Double {
        switch type {
        case "clothing": return Shopping.clothing
        case "electronics": return Shopping.electronics
        case "furniture": return Shopping.furniture
        case "books": return Shopping.books
        case "household": return Shopping.household
        default: return Shopping.household // Fallback
        }
    }
    
    private static func getEnergyFactor(type: String) -> Double {
        switch type {
        case "electricity": return Energy.electricity
        case "naturalGas": return Energy.naturalGas
        case "propane": return Energy.propane
        case "solar": return Energy.solar
        case "wind": return Energy.wind
        default: return Energy.electricity // Fallback
        }
    }
}

// MARK: - Emission Factors Version

struct EmissionFactorsVersion {
    static let current = "EPA-2024-Q1"
    static let lastUpdated = Date()
    static let source = "EPA Greenhouse Gas Emissions Standards"
    
    static func needsMigration(storedVersion: String?) -> Bool {
        guard let stored = storedVersion else {
            return true
        }
        return stored != current
    }
}
