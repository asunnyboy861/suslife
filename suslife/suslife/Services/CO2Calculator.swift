//
//  CO2Calculator.swift
//  suslife
//
//  CO2 Calculation Engine - Supports multiple regions with dynamic emission factors
//

import Foundation

struct CO2Calculator {
    
    static func calculate(
        category: String,
        activityType: String,
        value: Double,
        region: Region? = nil
    ) -> Double {
        guard value >= 0 else { return 0 }
        
        let selectedRegion = region ?? getCurrentRegion()
        let factors = selectedRegion.emissionFactors
        
        let factor = getEmissionFactor(
            category: category,
            activityType: activityType,
            factors: factors
        )
        
        return value * factor
    }
    
    static func calculateWithMetricValue(
        category: String,
        activityType: String,
        metricValue: Double,
        region: Region? = nil
    ) -> Double {
        let selectedRegion = region ?? getCurrentRegion()
        let unitSystem = getUnitSystem()
        
        var value = metricValue
        
        if category == "transport" && unitSystem == .imperial {
            value = metricValue / 1.60934
        }
        
        return calculate(category: category, activityType: activityType, value: value, region: selectedRegion)
    }
    
    private static func getCurrentRegion() -> Region {
        if let savedRegion = UserDefaults.standard.string(forKey: "selectedRegion"),
           let region = Region(rawValue: savedRegion) {
            return region
        }
        return Region.detectFromLocale()
    }
    
    private static func getUnitSystem() -> UnitSystem {
        if let savedUnitSystem = UserDefaults.standard.string(forKey: "unitSystem"),
           let system = UnitSystem(rawValue: savedUnitSystem) {
            return system
        }
        return getCurrentRegion().unitSystem
    }
    
    private static func getEmissionFactor(
        category: String,
        activityType: String,
        factors: RegionalEmissionFactors
    ) -> Double {
        switch category {
        case "transport":
            return getTransportFactor(type: activityType, factors: factors.transport)
        case "food":
            return getFoodFactor(type: activityType, factors: factors.food)
        case "shopping":
            return getShoppingFactor(type: activityType, factors: factors.shopping)
        case "energy":
            return getEnergyFactor(type: activityType, factors: factors.energy)
        default:
            return 0.0
        }
    }
    
    private static func getTransportFactor(type: String, factors: RegionalEmissionFactors.TransportFactors) -> Double {
        switch type {
        case "walking": return factors.walking
        case "bicycle": return factors.bicycle
        case "bus": return factors.bus
        case "train": return factors.train
        case "car": return factors.car
        case "flight": return factors.flight
        case "ev": return factors.ev
        default: return factors.car
        }
    }
    
    private static func getFoodFactor(type: String, factors: RegionalEmissionFactors.FoodFactors) -> Double {
        switch type {
        case "vegan": return factors.vegan
        case "vegetarian": return factors.vegetarian
        case "chicken": return factors.chicken
        case "pork": return factors.pork
        case "beef": return factors.beef
        case "fish": return factors.fish
        case "dairy": return factors.dairy
        default: return factors.vegetarian
        }
    }
    
    private static func getShoppingFactor(type: String, factors: RegionalEmissionFactors.ShoppingFactors) -> Double {
        switch type {
        case "clothing": return factors.clothing
        case "electronics": return factors.electronics
        case "furniture": return factors.furniture
        case "books": return factors.books
        case "household": return factors.household
        default: return factors.household
        }
    }
    
    private static func getEnergyFactor(type: String, factors: RegionalEmissionFactors.EnergyFactors) -> Double {
        switch type {
        case "electricity": return factors.electricity
        case "naturalGas": return factors.naturalGas
        case "propane": return factors.propane
        case "solar": return factors.solar
        case "wind": return factors.wind
        default: return factors.electricity
        }
    }
    
    @MainActor
    static func getEmissionFactorDescription(for category: String, activityType: String) -> String {
        let region = RegionManager.shared.currentRegion
        let factors = region.emissionFactors
        let factor = getEmissionFactor(category: category, activityType: activityType, factors: factors)
        let unit = RegionManager.shared.unitSystem == .imperial ? "lbs" : "kg"
        let distanceUnit = RegionManager.shared.unitSystem == .imperial ? "mile" : "km"
        
        switch category {
        case "transport":
            return String(format: "%.3f %@ CO₂/%@", factor, unit, distanceUnit)
        case "food":
            return String(format: "%.1f %@ CO₂/portion", factor, unit)
        case "shopping":
            return String(format: "%.1f %@ CO₂/item", factor, unit)
        case "energy":
            return String(format: "%.2f %@ CO₂/kWh", factor, unit)
        default:
            return ""
        }
    }
    
    @MainActor
    static func getRegionalInfo() -> (source: String, lastUpdated: String) {
        let region = RegionManager.shared.currentRegion
        let factors = region.emissionFactors
        return (factors.source, factors.lastUpdated)
    }
}

struct EmissionFactorsVersion {
    static func current() -> String {
        let region: Region
        if let savedRegion = UserDefaults.standard.string(forKey: "selectedRegion"),
           let saved = Region(rawValue: savedRegion) {
            region = saved
        } else {
            region = Region.detectFromLocale()
        }
        let factors = region.emissionFactors
        return "\(region.rawValue)-\(factors.lastUpdated)"
    }
    
    static let lastUpdated = Date()
    
    static func needsMigration(storedVersion: String?) -> Bool {
        guard let stored = storedVersion else {
            return true
        }
        return stored != current()
    }
}
