//
//  Colors.swift
//  suslife
//
//  Design System Colors - US Market
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors
    
    /// Primary green - main brand color
    static let primary = Color(hex: "2E7D32")
    
    /// Primary light variant
    static let primaryLight = Color(hex: "66BB6A")
    
    /// Primary dark variant
    static let primaryDark = Color(hex: "1B5E20")
    
    // MARK: - Secondary Colors
    
    /// Accent color for highlights
    static let accent = Color(hex: "81C784")
    
    /// Success color for positive actions
    static let success = Color(hex: "4CAF50")
    
    /// Warning color for cautions
    static let warning = Color(hex: "FFA726")
    
    /// Error color for alerts
    static let error = Color(hex: "EF5350")
    
    // MARK: - Neutral Colors
    
    /// Background color
    static let background = Color(hex: "F5F5F5")
    
    /// Card background
    static let cardBackground = Color(hex: "FFFFFF")
    
    /// Text primary
    static let textPrimary = Color(hex: "212121")
    
    /// Text secondary
    static let textSecondary = Color(hex: "757575")
    
    /// Divider color
    static let divider = Color(hex: "E0E0E0")
    
    // MARK: - Chart Colors
    
    static let chartColors = [
        Color(hex: "2E7D32"),
        Color(hex: "66BB6A"),
        Color(hex: "81C784"),
        Color(hex: "A5D6A7"),
        Color(hex: "C8E6C9")
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
