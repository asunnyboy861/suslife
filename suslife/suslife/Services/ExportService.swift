//
//  ExportService.swift
//  suslife
//
//  Export Service - Handles data export functionality
//

import Foundation
import UniformTypeIdentifiers
import UIKit
import LocalAuthentication

@MainActor
final class ExportService: ObservableObject {
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
    
    func exportToPDF() async throws -> URL {
        let totalCO2Saved = try await repository.calculateTotalCO2Saved()
        let totalActivities = try await repository.fetchTotalActivities()
        let weeklyTrend = try await repository.fetchWeeklyTrend()
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "suslife_report_\(dateFormatter.string(from: Date())).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try pdfRenderer.writePDF(to: tempURL) { context in
            context.beginPage()
            
            let title = "Sustainable Life Report"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: 306 - titleSize.width / 2, y: 50), withAttributes: titleAttributes)
            
            let dateStr = "Generated on \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let dateSize = dateStr.size(withAttributes: dateAttributes)
            dateStr.draw(at: CGPoint(x: 306 - dateSize.width / 2, y: 80), withAttributes: dateAttributes)
            
            var yPosition: CGFloat = 150
            
            let stats = [
                "Total CO2 Saved: \(String(format: "%.1f", totalCO2Saved)) lbs",
                "Total Activities: \(totalActivities)",
                "Weekly Average: \(String(format: "%.1f", weeklyTrend.isEmpty ? 0 : weeklyTrend.reduce(0) { $0 + $1.totalCO2 } / Double(weeklyTrend.count))) lbs"
            ]
            
            for stat in stats {
                let statAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                stat.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: statAttributes)
                yPosition += 40
            }
            
            yPosition += 30
            let chartTitle = "Weekly Trend:"
            let chartAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
            chartTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: chartAttributes)
            yPosition += 30
            
            let maxCO2 = weeklyTrend.map { $0.totalCO2 }.max() ?? 1
            for daily in weeklyTrend {
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEE"
                let dayName = dayFormatter.string(from: daily.date)
                
                let barLength = maxCO2 > 0 ? Int(daily.totalCO2 / maxCO2 * 200) : 0
                let bar = String(repeating: "█", count: max(1, barLength))
                
                let line = "\(dayName): \(bar) (\(String(format: "%.1f", daily.totalCO2)) lbs)"
                let lineAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                line.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: lineAttributes)
                yPosition += 20
            }
        }
        
        return tempURL
    }
    
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to export your data"
            )
            return success
        } catch {
            print("Biometric authentication error: \(error)")
            return false
        }
    }
}
