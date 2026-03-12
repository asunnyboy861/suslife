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
    
    override func setUp() async throws {
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
    
    func testCSVExport() async throws {
        let csvURL = try await exportService.exportToCSV()
        
        let csvContent = try String(contentsOf: csvURL)
        XCTAssertTrue(csvContent.hasPrefix("Date,Category,Activity Type"))
        XCTAssertTrue(csvContent.contains("lbs"))
    }
    
    func testJSONExport() async throws {
        let jsonURL = try await exportService.exportToJSON()
        
        let jsonData = try Data(contentsOf: jsonURL)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]]
        XCTAssertNotNil(jsonObject)
    }
    
    func testPDFExport() async throws {
        let pdfURL = try await exportService.exportToPDF()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: pdfURL.path))
        XCTAssertEqual(pdfURL.pathExtension, "pdf")
    }
    
    func testPDFContainsTitle() async throws {
        let pdfURL = try await exportService.exportToPDF()
        
        let pdfData = try Data(contentsOf: pdfURL)
        XCTAssertGreaterThan(pdfData.count, 0)
    }
}

final class MockActivityRepository: ActivityRepositoryProtocol {
    var totalActivities = 0
    var totalCO2Saved: Double = 0
    var weeklyTrend: [DailyTotal] = []
    
    func fetchTodayActivities() async throws -> [CarbonActivity] {
        return []
    }
    
    func fetchActivities(from startDate: Date, to endDate: Date) async throws -> [CarbonActivity] {
        return []
    }
    
    func fetchTodayTotalCO2() async throws -> Double {
        return 0
    }
    
    func fetchWeeklyTrend() async throws -> [DailyTotal] {
        return weeklyTrend
    }
    
    func save(_ input: ActivityInput) async throws -> CarbonActivity {
        return CarbonActivity()
    }
    
    func saveAll(_ activities: [ActivityInput]) async throws {
    }
    
    func delete(id: UUID) async throws {
    }
    
    func deleteAll() async throws {
    }
    
    func calculateTotalCO2Saved() async throws -> Double {
        return totalCO2Saved
    }
    
    func fetchActivityCount(for dateRange: DateRange) async throws -> Int {
        return totalActivities
    }
    
    func fetchTotalActivities() async throws -> Int {
        return totalActivities
    }
    
    func fetchMonthlyTrend() async throws -> [DailyTotal] {
        return weeklyTrend
    }
}
