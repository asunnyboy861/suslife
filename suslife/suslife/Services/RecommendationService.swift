//
//  RecommendationService.swift
//  suslife
//
//  Recommendation Service - Personalized sustainability tips
//

import Foundation

struct Recommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: RecommendationCategory
    let potentialCO2: Double
    let iconName: String
    
    var formattedPotential: String {
        String(format: "%.1f lbs", potentialCO2)
    }
}

enum RecommendationCategory: String, CaseIterable {
    case transport = "Transport"
    case energy = "Energy"
    case food = "Food"
    case shopping = "Shopping"
    case lifestyle = "Lifestyle"
    
    var iconName: String {
        switch self {
        case .transport: return "car.fill"
        case .energy: return "bolt.fill"
        case .food: return "fork.knife"
        case .shopping: return "bag.fill"
        case .lifestyle: return "heart.fill"
        }
    }
}

final class RecommendationService: ObservableObject {
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol = CoreDataActivityRepository()) {
        self.repository = repository
    }
    
    func getRecommendations() async throws -> [Recommendation] {
        let activities = try await repository.fetchActivities(from: .distantPast, to: Date())
        let categoryCount = Dictionary(grouping: activities, by: { $0.category })
        
        var recommendations: [Recommendation] = []
        
        recommendations.append(contentsOf: getGeneralRecommendations())
        
        if let walkingCount = categoryCount["Walking"]?.count, walkingCount < 3 {
            recommendations.append(Recommendation(
                title: "More Walking",
                description: "Try walking to nearby destinations instead of driving. It's great for your health and the planet!",
                category: .transport,
                potentialCO2: 5.0,
                iconName: "figure.walk"
            ))
        }
        
        if let transitCount = categoryCount["Public Transit"]?.count, transitCount < 2 {
            recommendations.append(Recommendation(
                title: "Take Public Transit",
                description: "Consider taking public transportation for your commute. It reduces emissions significantly!",
                category: .transport,
                potentialCO2: 10.0,
                iconName: "bus.fill"
            ))
        }
        
        if let bikeCount = categoryCount["Cycling"]?.count, bikeCount < 1 {
            recommendations.append(Recommendation(
                title: "Try Cycling",
                description: "Cycling is a zero-emission way to commute. Great exercise too!",
                category: .transport,
                potentialCO2: 8.0,
                iconName: "bicycle"
            ))
        }
        
        if activities.count < 7 {
            recommendations.append(Recommendation(
                title: "Log More Activities",
                description: "Track your daily sustainable actions to see your impact grow!",
                category: .lifestyle,
                potentialCO2: 3.0,
                iconName: "checkmark.circle.fill"
            ))
        }
        
        recommendations.append(Recommendation(
            title: "Meatless Mondays",
            description: "Try going meat-free one day a week. Livestock accounts for significant emissions.",
            category: .food,
            potentialCO2: 8.0,
            iconName: "leaf.fill"
        ))
        
        recommendations.append(Recommendation(
            title: "Unplug Devices",
            description: "Unplug chargers and electronics when not in use to save energy.",
            category: .energy,
            potentialCO2: 2.0,
            iconName: "powerplug.fill"
        ))
        
        recommendations.append(Recommendation(
            title: "Bring Reusable Bags",
            description: "Use reusable bags when shopping to reduce plastic waste.",
            category: .shopping,
            potentialCO2: 0.5,
            iconName: "bag.fill"
        ))
        
        return recommendations.shuffled().prefix(5).map { $0 }
    }
    
    private func getGeneralRecommendations() -> [Recommendation] {
        return [
            Recommendation(
                title: "Carpool When Possible",
                description: "Sharing rides with others reduces the number of vehicles on the road.",
                category: .transport,
                potentialCO2: 15.0,
                iconName: "car.side.fill"
            ),
            Recommendation(
                title: "Switch to LED Bulbs",
                description: "LED bulbs use up to 75% less energy than traditional bulbs.",
                category: .energy,
                potentialCO2: 5.0,
                iconName: "lightbulb.fill"
            ),
            Recommendation(
                title: "Buy Local Produce",
                description: "Local food travels shorter distances, reducing transportation emissions.",
                category: .food,
                potentialCO2: 3.0,
                iconName: "cart.fill"
            ),
            Recommendation(
                title: "Cold Water Wash",
                description: "Washing clothes in cold water saves energy and is gentler on fabrics.",
                category: .lifestyle,
                potentialCO2: 2.0,
                iconName: "washer.fill"
            )
        ]
    }
}
