//
//  Fonts.swift
//  suslife
//
//  Typography Scale - SF Pro Font Family
//

import SwiftUI

struct Fonts {
    // MARK: - Display Fonts
    
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 20, weight: .medium, design: .default)
    
    // MARK: - Text Fonts
    
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    
    // MARK: - Caption Fonts
    
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // MARK: - Custom Fonts
    
    /// SF Pro Rounded for friendly, approachable UI
    static let roundedBody = Font.system(size: 17, weight: .regular, design: .rounded)
    static let roundedHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
}
