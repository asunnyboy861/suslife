//
//  ExportServiceTests.swift
//  suslifeTests
//
//  Export Service Tests
//

import XCTest
@testable import suslife

final class ExportServiceTests: XCTestCase {
    
    var exportService: ExportService!
    var mockRepository: MockActivityRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockActivityRepository()
        exportService = ExportService(repository: mockRepository)
    }
    
    func testGenerateShareTextContainsKeyMetrics() async throws {
        let shareText = try await exportService.generateShareText()
        
        XCTAssertTrue(shareText.contains("Total CO2 Saved"))
        XCTAssertTrue(shareText.contains("Activities Logged"))
        XCTAssertTrue(shareText.contains("This Week"))
    }
    
    func testGenerateShareTextContainsEmoji() async throws {
        let shareText = try await exportService.generateShareText()
        
        XCTAssertTrue(shareText.contains("🌱"))
    }
}
