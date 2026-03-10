//
//  RecommendationServiceTests.swift
//  suslifeTests
//
//  Recommendation Service Tests
//

import XCTest
@testable import suslife

final class RecommendationServiceTests: XCTestCase {
    
    var recommendationService: RecommendationService!
    var mockRepository: MockActivityRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockActivityRepository()
        recommendationService = RecommendationService(repository: mockRepository)
    }
    
    func testGetRecommendationsReturnsNonEmpty() async throws {
        let recommendations = try await recommendationService.getRecommendations()
        XCTAssertFalse(recommendations.isEmpty)
    }
    
    func testRecommendationsHaveValidCategories() async throws {
        let recommendations = try await recommendationService.getRecommendations()
        
        for recommendation in recommendations {
            XCTAssertFalse(recommendation.title.isEmpty)
            XCTAssertFalse(recommendation.description.isEmpty)
            XCTAssertGreaterThan(recommendation.potentialCO2, 0)
        }
    }
    
    func testRecommendationsAreLimited() async throws {
        let recommendations = try await recommendationService.getRecommendations()
        XCTAssertLessThanOrEqual(recommendations.count, 5)
    }
}
