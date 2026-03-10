//
//  ExportService.swift
//  suslife
//
//  Export Service - Handles data export functionality
//

import Foundation
import UniformTypeIdentifiers

final class ExportService {
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol = CoreDataActivityRepository()) {
        self.repository = repository
    }
    
    func exportToCSV() async throws -> URL {
        let activities = try await repository.fetchActivities(from: .distantPast, to: Date())
        
        var csvContent = "Date,Category,Activity Type,Value,Unit,CO2 Saved (lbs),Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for activity in activities {
            let row = [
                dateFormatter.string(from: activity.date),
                activity.category ?? "",
                activity.activityType ?? "",
                String(format: "%.2f", activity.value),
                activity.unit ?? "",
                String(format: "%.2f", activity.co2Emission),
                activity.notes ?? ""
            ].joined(separator: ",")
            
            csvContent += row + "\n"
        }
        
        let fileName = "suslife_export_\(dateFormatter.string(from: Date())).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
        
        return tempURL
    }
    
    func exportToJSON() async throws -> URL {
        let activities = try await repository.fetchActivities(from: .distantPast, to: Date())
        
        let exportData = activities.map { activity -> [String: Any] in
            var dict: [String: Any] = [
                "id": activity.id.uuidString,
                "date": ISO8601DateFormatter().string(from: activity.date),
                "category": activity.category ?? "",
                "activityType": activity.activityType ?? "",
                "value": activity.value,
                "unit": activity.unit ?? "",
                "co2Emission": activity.co2Emission
            ]
            
            if let notes = activity.notes {
                dict["notes"] = notes
            }
            
            return dict
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let fileName = "suslife_export_\(dateFormatter.string(from: Date())).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try jsonData.write(to: tempURL)
        
        return tempURL
    }
    
    func generateShareText() async throws -> String {
        let totalCO2Saved = try await repository.calculateTotalCO2Saved()
        let totalActivities = try await repository.fetchTotalActivities()
        let weeklyTrend = try await repository.fetchWeeklyTrend()
        
        let weeklyTotal = weeklyTrend.reduce(0.0) { $0 + $1.totalCO2 }
        
        var shareText = """
        🌱 My Sustainability Journey with SusLife
        
        📊 Total CO2 Saved: \(String(format: "%.1f", totalCO2Saved)) lbs
        ✅ Activities Logged: \(totalActivities)
        📅 This Week: \(String(format: "%.1f", weeklyTotal)) lbs saved
        
        Join me in making a difference!
        """
        
        return shareText
    }
}
