//
//  CO2CalculatorTests.swift
//  suslifeTests
//
//  Unit Tests for CO2 Calculator
//

import XCTest
@testable import suslife

final class CO2CalculatorTests: XCTestCase {
    
    // MARK: - Transport Tests
    
    func testTransportCarCalculation() {
        // 10 miles * 0.13 lbs/mile = 1.3 lbs
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: 10.0
        )
        XCTAssertEqual(result, 1.3, accuracy: 0.01)
    }
    
    func testTransportBusCalculation() {
        // 5 miles * 0.055 lbs/mile = 0.275 lbs
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "bus",
            value: 5.0
        )
        XCTAssertEqual(result, 0.275, accuracy: 0.01)
    }
    
    func testTransportWalkingZeroEmission() {
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "walking",
            value: 5.0
        )
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }
    
    func testTransportBicycleZeroEmission() {
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "bicycle",
            value: 10.0
        )
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }
    
    func testTransportEVCalculation() {
        // 100 miles * 0.065 lbs/mile = 6.5 lbs
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "ev",
            value: 100.0
        )
        XCTAssertEqual(result, 6.5, accuracy: 0.01)
    }
    
    func testTransportFlightCalculation() {
        // 500 miles * 0.159 lbs/mile = 79.5 lbs
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "flight",
            value: 500.0
        )
        XCTAssertEqual(result, 79.5, accuracy: 0.01)
    }
    
    // MARK: - Food Tests
    
    func testFoodBeefCalculation() {
        // 2 portions * 13.2 lbs/portion = 26.4 lbs
        let result = CO2Calculator.calculate(
            category: "food",
            activityType: "beef",
            value: 2.0
        )
        XCTAssertEqual(result, 26.4, accuracy: 0.01)
    }
    
    func testFoodVeganCalculation() {
        // 3 portions * 1.1 lbs/portion = 3.3 lbs
        let result = CO2Calculator.calculate(
            category: "food",
            activityType: "vegan",
            value: 3.0
        )
        XCTAssertEqual(result, 3.3, accuracy: 0.01)
    }
    
    func testFoodChickenCalculation() {
        // 1 portion * 5.1 lbs/portion = 5.1 lbs
        let result = CO2Calculator.calculate(
            category: "food",
            activityType: "chicken",
            value: 1.0
        )
        XCTAssertEqual(result, 5.1, accuracy: 0.01)
    }
    
    // MARK: - Shopping Tests
    
    func testShoppingClothingCalculation() {
        // 5 items * 22.0 lbs/item = 110 lbs
        let result = CO2Calculator.calculate(
            category: "shopping",
            activityType: "clothing",
            value: 5.0
        )
        XCTAssertEqual(result, 110.0, accuracy: 0.01)
    }
    
    func testShoppingElectronicsCalculation() {
        // 1 item * 110.0 lbs/item = 110 lbs
        let result = CO2Calculator.calculate(
            category: "shopping",
            activityType: "electronics",
            value: 1.0
        )
        XCTAssertEqual(result, 110.0, accuracy: 0.01)
    }
    
    // MARK: - Energy Tests
    
    func testEnergyElectricityCalculation() {
        // 10 kWh * 1.88 lbs/kWh = 18.8 lbs
        let result = CO2Calculator.calculate(
            category: "energy",
            activityType: "electricity",
            value: 10.0
        )
        XCTAssertEqual(result, 18.8, accuracy: 0.01)
    }
    
    func testEnergySolarZeroEmission() {
        let result = CO2Calculator.calculate(
            category: "energy",
            activityType: "solar",
            value: 100.0
        )
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }
    
    // MARK: - Edge Case Tests
    
    func testZeroValue() {
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: 0.0
        )
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }
    
    func testNegativeValue() {
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: -10.0
        )
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }
    
    func testLargeValue() {
        // 10000 miles * 0.13 lbs/mile = 1300 lbs
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: 10_000
        )
        XCTAssertEqual(result, 1300.0, accuracy: 0.01)
    }
    
    func testSmallValue() {
        // 0.1 miles * 0.13 lbs/mile = 0.013 lbs
        let result = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: 0.1
        )
        XCTAssertEqual(result, 0.013, accuracy: 0.001)
    }
    
    // MARK: - Category Tests
    
    func testAllCategoriesCovered() {
        let categories = ["transport", "food", "shopping", "energy"]
        
        for category in categories {
            let result = CO2Calculator.calculate(
                category: category,
                activityType: "default",
                value: 1.0
            )
            XCTAssertGreaterThanOrEqual(result, 0.0)
        }
    }
    
    func testUnknownCategoryReturnsZero() {
        let result = CO2Calculator.calculate(
            category: "unknown",
            activityType: "test",
            value: 10.0
        )
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }
    
    // MARK: - Emission Factor Version Tests
    
    func testEmissionFactorVersionExists() {
        XCTAssertFalse(EmissionFactorsVersion.current.isEmpty)
        XCTAssertEqual(EmissionFactorsVersion.current, "EPA-2024-Q1")
    }
    
    func testEmissionFactorVersionMigration() {
        // No stored version - needs migration
        XCTAssertTrue(EmissionFactorsVersion.needsMigration(storedVersion: nil))
        
        // Old version - needs migration
        XCTAssertTrue(EmissionFactorsVersion.needsMigration(storedVersion: "EPA-2023-Q4"))
        
        // Current version - no migration needed
        XCTAssertFalse(EmissionFactorsVersion.needsMigration(storedVersion: "EPA-2024-Q1"))
    }
    
    // MARK: - Performance Test
    
    func testCalculationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = CO2Calculator.calculate(
                    category: "transport",
                    activityType: "car",
                    value: Double.random(in: 0...100)
                )
            }
        }
    }
}
