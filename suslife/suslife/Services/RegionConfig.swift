//
//  RegionConfig.swift
//  suslife
//
//  Region Configuration - Supports multiple regions with different units and emission factors
//

import Foundation
import SwiftUI

enum Region: String, CaseIterable, Codable {
    case unitedStates = "US"
    case sweden = "SE"
    case germany = "DE"
    case france = "FR"
    case unitedKingdom = "GB"
    case norway = "NO"
    case denmark = "DK"
    case finland = "FI"
    case spain = "ES"
    case italy = "IT"
    case netherlands = "NL"
    case poland = "PL"
    
    var displayName: String {
        switch self {
        case .unitedStates: return "United States"
        case .sweden: return "Sweden (Sverige)"
        case .germany: return "Germany (Deutschland)"
        case .france: return "France"
        case .unitedKingdom: return "United Kingdom"
        case .norway: return "Norway (Norge)"
        case .denmark: return "Denmark (Danmark)"
        case .finland: return "Finland (Suomi)"
        case .spain: return "Spain (España)"
        case .italy: return "Italy (Italia)"
        case .netherlands: return "Netherlands (Nederland)"
        case .poland: return "Poland (Polska)"
        }
    }
    
    var flagEmoji: String {
        switch self {
        case .unitedStates: return "🇺🇸"
        case .sweden: return "🇸🇪"
        case .germany: return "🇩🇪"
        case .france: return "🇫🇷"
        case .unitedKingdom: return "🇬🇧"
        case .norway: return "🇳🇴"
        case .denmark: return "🇩🇰"
        case .finland: return "🇫🇮"
        case .spain: return "🇪🇸"
        case .italy: return "🇮🇹"
        case .netherlands: return "🇳🇱"
        case .poland: return "🇵🇱"
        }
    }
    
    var unitSystem: UnitSystem {
        switch self {
        case .unitedStates, .unitedKingdom:
            return .imperial
        default:
            return .metric
        }
    }
    
    var emissionFactors: RegionalEmissionFactors {
        switch self {
        case .unitedStates:
            return RegionalEmissionFactors.us
        case .sweden:
            return RegionalEmissionFactors.sweden
        case .germany:
            return RegionalEmissionFactors.germany
        case .france:
            return RegionalEmissionFactors.france
        case .unitedKingdom:
            return RegionalEmissionFactors.uk
        case .norway:
            return RegionalEmissionFactors.norway
        case .denmark:
            return RegionalEmissionFactors.denmark
        case .finland:
            return RegionalEmissionFactors.finland
        case .spain:
            return RegionalEmissionFactors.spain
        case .italy:
            return RegionalEmissionFactors.italy
        case .netherlands:
            return RegionalEmissionFactors.netherlands
        case .poland:
            return RegionalEmissionFactors.poland
        }
    }
    
    var defaultDailyGoal: Double {
        switch self {
        case .unitedStates:
            return 28.0
        case .unitedKingdom:
            return 12.0
        default:
            return 10.0
        }
    }
    
    static func detectFromLocale() -> Region {
        let locale = Locale.current
        
        if let regionCode = locale.region?.identifier {
            return Region(rawValue: regionCode) ?? .unitedStates
        }
        
        return .unitedStates
    }
}

enum UnitSystem: String, Codable {
    case imperial
    case metric
    
    var distanceUnit: String {
        switch self {
        case .imperial: return "mi"
        case .metric: return "km"
        }
    }
    
    var weightUnit: String {
        switch self {
        case .imperial: return "lbs"
        case .metric: return "kg"
        }
    }
    
    var distanceUnitName: String {
        switch self {
        case .imperial: return "miles"
        case .metric: return "kilometers"
        }
    }
    
    var weightUnitName: String {
        switch self {
        case .imperial: return "pounds"
        case .metric: return "kilograms"
        }
    }
}

struct RegionalEmissionFactors: Codable {
    let transport: TransportFactors
    let food: FoodFactors
    let shopping: ShoppingFactors
    let energy: EnergyFactors
    let source: String
    let lastUpdated: String
    
    struct TransportFactors: Codable {
        let walking: Double
        let bicycle: Double
        let bus: Double
        let train: Double
        let car: Double
        let flight: Double
        let ev: Double
    }
    
    struct FoodFactors: Codable {
        let vegan: Double
        let vegetarian: Double
        let chicken: Double
        let pork: Double
        let beef: Double
        let fish: Double
        let dairy: Double
    }
    
    struct ShoppingFactors: Codable {
        let clothing: Double
        let electronics: Double
        let furniture: Double
        let books: Double
        let household: Double
    }
    
    struct EnergyFactors: Codable {
        let electricity: Double
        let naturalGas: Double
        let propane: Double
        let solar: Double
        let wind: Double
    }
    
    static let us = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.055,
            train: 0.025,
            car: 0.13,
            flight: 0.159,
            ev: 0.065
        ),
        food: FoodFactors(
            vegan: 1.1,
            vegetarian: 2.2,
            chicken: 5.1,
            pork: 7.7,
            beef: 13.2,
            fish: 5.1,
            dairy: 3.3
        ),
        shopping: ShoppingFactors(
            clothing: 22.0,
            electronics: 110.0,
            furniture: 66.0,
            books: 3.3,
            household: 11.0
        ),
        energy: EnergyFactors(
            electricity: 1.88,
            naturalGas: 11.7,
            propane: 10.4,
            solar: 0.0,
            wind: 0.0
        ),
        source: "EPA 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let sweden = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.015
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.02,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "Swedish EPA (Naturvårdsverket) 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let germany = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.09
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.85,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "Umweltbundesamt 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let france = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.03
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.10,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "ADEME 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let uk = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.08
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.45,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "UK Government GHG Conversion Factors 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let norway = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.01
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.015,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "Miljødirektoratet 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let denmark = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.04
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.25,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "Danish Energy Agency 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let finland = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.03
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.20,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "Finnish Environment Institute 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let spain = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.10
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.35,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "MITECO 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let italy = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.12
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.40,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "ISPRA 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let netherlands = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.11
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.50,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "RIVM 2024",
        lastUpdated: "2024-01-01"
    )
    
    static let poland = RegionalEmissionFactors(
        transport: TransportFactors(
            walking: 0.0,
            bicycle: 0.0,
            bus: 0.089,
            train: 0.041,
            car: 0.21,
            flight: 0.255,
            ev: 0.25
        ),
        food: FoodFactors(
            vegan: 0.5,
            vegetarian: 1.0,
            chicken: 2.3,
            pork: 3.5,
            beef: 6.0,
            fish: 2.3,
            dairy: 1.5
        ),
        shopping: ShoppingFactors(
            clothing: 10.0,
            electronics: 50.0,
            furniture: 30.0,
            books: 1.5,
            household: 5.0
        ),
        energy: EnergyFactors(
            electricity: 0.90,
            naturalGas: 2.0,
            propane: 1.8,
            solar: 0.0,
            wind: 0.0
        ),
        source: "KOBiZE 2024",
        lastUpdated: "2024-01-01"
    )
}

@MainActor
final class RegionManager: ObservableObject {
    static let shared = RegionManager()
    
    @Published var currentRegion: Region {
        didSet {
            UserDefaults.standard.set(currentRegion.rawValue, forKey: "selectedRegion")
        }
    }
    
    @Published var unitSystem: UnitSystem {
        didSet {
            UserDefaults.standard.set(unitSystem.rawValue, forKey: "unitSystem")
        }
    }
    
    private init() {
        let region: Region
        if let savedRegion = UserDefaults.standard.string(forKey: "selectedRegion"),
           let saved = Region(rawValue: savedRegion) {
            region = saved
        } else {
            region = Region.detectFromLocale()
        }
        self.currentRegion = region
        
        if let savedUnitSystem = UserDefaults.standard.string(forKey: "unitSystem"),
           let system = UnitSystem(rawValue: savedUnitSystem) {
            self.unitSystem = system
        } else {
            self.unitSystem = region.unitSystem
        }
    }
    
    var emissionFactors: RegionalEmissionFactors {
        currentRegion.emissionFactors
    }
    
    func setRegion(_ region: Region) {
        currentRegion = region
        unitSystem = region.unitSystem
    }
    
    func setUnitSystem(_ system: UnitSystem) {
        unitSystem = system
    }
    
    var distanceUnit: String { unitSystem.distanceUnit }
    var weightUnit: String { unitSystem.weightUnit }
    var co2Unit: String { unitSystem == .imperial ? "lbs CO₂" : "kg CO₂" }
    
    func formatCO2(_ value: Double) -> String {
        let displayValue = unitSystem == .imperial ? value : value * 0.453592
        let unit = unitSystem == .imperial ? "lbs" : "kg"
        return String(format: "%.1f %@", displayValue, unit)
    }
    
    func formatDistance(_ value: Double) -> String {
        let displayValue = unitSystem == .imperial ? value : value * 1.60934
        let unit = unitSystem.distanceUnit
        return String(format: "%.1f %@", displayValue, unit)
    }
    
    func convertInputDistance(_ value: Double) -> Double {
        if unitSystem == .metric {
            return value / 1.60934
        }
        return value
    }
    
    func convertInputCO2(_ value: Double) -> Double {
        if unitSystem == .metric {
            return value / 0.453592
        }
        return value
    }
}
