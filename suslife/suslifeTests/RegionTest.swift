//
//  RegionTest.swift
//  suslife
//
//  Test file for region configuration
//

import XCTest
@testable import suslife

final class RegionTest: XCTestCase {
    
    func testRegionDetection() {
        let detectedRegion = Region.detectFromLocale()
        XCTAssertNotNil(detectedRegion)
        print("✅ Detected Region: \(detectedRegion.displayName)")
    }
    
    func testAllRegionsHaveEmissionFactors() {
        for region in Region.allCases {
            let factors = region.emissionFactors
            XCTAssertNotNil(factors)
            XCTAssertGreaterThan(factors.transport.car, 0)
            print("✅ \(region.displayName): car emission = \(factors.transport.car)")
        }
    }
    
    func testUnitSystemForRegions() {
        XCTAssertEqual(Region.unitedStates.unitSystem, .imperial)
        XCTAssertEqual(Region.sweden.unitSystem, .metric)
        XCTAssertEqual(Region.germany.unitSystem, .metric)
        XCTAssertEqual(Region.unitedKingdom.unitSystem, .imperial)
        print("✅ Unit systems correctly configured")
    }
    
    func testCO2Calculation() {
        let usCO2 = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: 10,
            region: .unitedStates
        )
        XCTAssertEqual(usCO2, 1.3, accuracy: 0.01)
        print("✅ US car 10 miles = \(usCO2) lbs CO2")
        
        let swedenCO2 = CO2Calculator.calculate(
            category: "transport",
            activityType: "car",
            value: 10,
            region: .sweden
        )
        XCTAssertEqual(swedenCO2, 2.1, accuracy: 0.01)
        print("✅ Sweden car 10 km = \(swedenCO2) kg CO2")
    }
    
    func testSwedenLowCarbonGrid() {
        let swedenFactors = Region.sweden.emissionFactors
        let usFactors = Region.unitedStates.emissionFactors
        
        XCTAssertLessThan(swedenFactors.energy.electricity, usFactors.energy.electricity)
        print("✅ Sweden electricity: \(swedenFactors.energy.electricity) vs US: \(usFactors.energy.electricity)")
    }
    
    func testRegionFlags() {
        XCTAssertEqual(Region.sweden.flagEmoji, "🇸🇪")
        XCTAssertEqual(Region.germany.flagEmoji, "🇩🇪")
        XCTAssertEqual(Region.france.flagEmoji, "🇫🇷")
        print("✅ Region flags correctly configured")
    }
    
    func testEmissionFactorsVersion() {
        let version = EmissionFactorsVersion.current()
        XCTAssertFalse(version.isEmpty)
        print("✅ Emission factors version: \(version)")
    }
}
