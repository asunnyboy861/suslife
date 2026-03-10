//
//  ActivityValidator.swift
//  suslife
//
//  Data Validation Layer - Prevents invalid data entry
//

import Foundation

enum ValidationError: LocalizedError {
    case invalidCategory(String)
    case invalidActivityType(String)
    case negativeValue
    case valueTooLarge(Double)
    case invalidUnit(String)
    case futureDate(Date)
    
    var errorDescription: String? {
        switch self {
        case .invalidCategory(let category):
            return "Invalid category: '\(category)'. Must be transport, food, shopping, or energy."
        case .invalidActivityType(let type):
            return "Invalid activity type: '\(type)'."
        case .negativeValue:
            return "Value cannot be negative."
        case .valueTooLarge(let value):
            return "Value \(value) is too large. Maximum allowed is 10,000."
        case .invalidUnit(let unit):
            return "Invalid unit: '\(unit)'."
        case .futureDate(let date):
            return "Activity date cannot be in the future: \(date)."
        }
    }
}

struct ValidationResult {
    let isValid: Bool
    let error: ValidationError?
    
    static let valid = ValidationResult(isValid: true, error: nil)
    static func invalid(_ error: ValidationError) -> ValidationResult {
        ValidationResult(isValid: false, error: error)
    }
}

protocol ActivityValidatable {
    func validate() -> ValidationResult
}

extension ActivityInput: ActivityValidatable {
    func validate() -> ValidationResult {
        // 1. Validate category
        let validCategories = ["transport", "food", "shopping", "energy"]
        guard validCategories.contains(category) else {
            return .invalid(.invalidCategory(category))
        }
        
        // 2. Validate value
        guard value >= 0 else {
            return .invalid(.negativeValue)
        }
        
        guard value <= 10_000 else {
            return .invalid(.valueTooLarge(value))
        }
        
        // 3. Validate unit
        let validUnits = ["mi", "portion", "item", "kWh", "lbs", "kg"]
        guard validUnits.contains(unit) else {
            return .invalid(.invalidUnit(unit))
        }
        
        // 4. Validate date (not in future)
        guard date <= Date() else {
            return .invalid(.futureDate(date))
        }
        
        // 5. Validate activity type for category
        if !isValidActivityType(activityType, for: category) {
            return .invalid(.invalidActivityType(activityType))
        }
        
        return .valid
    }
    
    private func isValidActivityType(_ type: String, for category: String) -> Bool {
        let validTypes: [String: [String]] = [
            "transport": ["walking", "bicycle", "bus", "train", "car", "flight", "ev"],
            "food": ["vegan", "vegetarian", "chicken", "pork", "beef", "fish", "dairy"],
            "shopping": ["clothing", "electronics", "furniture", "books", "household"],
            "energy": ["electricity", "naturalGas", "propane", "solar", "wind"]
        ]
        
        return validTypes[category]?.contains(type) ?? false
    }
}
