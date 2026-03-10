//
//  ActivityValidatorTests.swift
//  suslifeTests
//
//  Validation Layer Unit Tests
//

import XCTest
@testable import suslife

final class ActivityValidatorTests: XCTestCase {
    
    func testValidInput() {
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: 10.0,
            unit: "mi",
            notes: "Valid commute",
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.error)
    }
    
    func testInvalidCategory() {
        let input = ActivityInput(
            category: "invalid_category",
            activityType: "car",
            value: 10.0,
            unit: "mi",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertFalse(result.isValid)
        
        if case .invalidCategory? = result.error {
            // Expected
        } else {
            XCTFail("Expected invalidCategory error")
        }
    }
    
    func testNegativeValue() {
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: -5.0,
            unit: "mi",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertFalse(result.isValid)
        
        if case .negativeValue? = result.error {
            // Expected
        } else {
            XCTFail("Expected negativeValue error")
        }
    }
    
    func testValueTooLarge() {
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: 100_001, // Exceeds 10,000 limit
            unit: "mi",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertFalse(result.isValid)
        
        if case .valueTooLarge? = result.error {
            // Expected
        } else {
            XCTFail("Expected valueTooLarge error")
        }
    }
    
    func testFutureDate() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: 10.0,
            unit: "mi",
            notes: nil,
            date: futureDate
        )
        
        let result = input.validate()
        XCTAssertFalse(result.isValid)
        
        if case .futureDate? = result.error {
            // Expected
        } else {
            XCTFail("Expected futureDate error")
        }
    }
    
    func testInvalidActivityTypeForCategory() {
        // Beef is food, not transport
        let input = ActivityInput(
            category: "transport",
            activityType: "beef",
            value: 2.0,
            unit: "portion",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertFalse(result.isValid)
        
        if case .invalidActivityType? = result.error {
            // Expected
        } else {
            XCTFail("Expected invalidActivityType error")
        }
    }
    
    func testValidFoodInput() {
        let input = ActivityInput(
            category: "food",
            activityType: "beef",
            value: 2.0,
            unit: "portion",
            notes: "Lunch",
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertTrue(result.isValid)
    }
    
    func testValidShoppingInput() {
        let input = ActivityInput(
            category: "shopping",
            activityType: "clothing",
            value: 3.0,
            unit: "item",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertTrue(result.isValid)
    }
    
    func testValidEnergyInput() {
        let input = ActivityInput(
            category: "energy",
            activityType: "electricity",
            value: 15.0,
            unit: "kWh",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertTrue(result.isValid)
    }
    
    func testZeroValueIsValid() {
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: 0.0,
            unit: "mi",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertTrue(result.isValid)
    }
    
    func testInvalidUnit() {
        let input = ActivityInput(
            category: "transport",
            activityType: "car",
            value: 10.0,
            unit: "invalid_unit",
            notes: nil,
            date: Date()
        )
        
        let result = input.validate()
        XCTAssertFalse(result.isValid)
        
        if case .invalidUnit? = result.error {
            // Expected
        } else {
            XCTFail("Expected invalidUnit error")
        }
    }
}
