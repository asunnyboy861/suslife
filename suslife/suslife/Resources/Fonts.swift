//
//  Fonts.swift
//  suslife
//
//  Typography Scale - SF Pro Font Family (Dynamic Type Supported)
//

import SwiftUI

struct Fonts {
    // MARK: - Display Fonts (Dynamic Type Supported)
    
    static var largeTitle: Font {
        .system(.largeTitle, design: .default)
    }
    
    static var title1: Font {
        .system(.title, design: .default)
    }
    
    static var title2: Font {
        .system(.title2, design: .default)
    }
    
    static var title3: Font {
        .system(.title3, design: .default)
    }
    
    // MARK: - Text Fonts
    
    static var headline: Font {
        .system(.headline, design: .default)
    }
    
    static var body: Font {
        .system(.body, design: .default)
    }
    
    static var callout: Font {
        .system(.callout, design: .default)
    }
    
    static var subheadline: Font {
        .system(.subheadline, design: .default)
    }
    
    // MARK: - Caption Fonts
    
    static var footnote: Font {
        .system(.footnote, design: .default)
    }
    
    static var caption1: Font {
        .system(.caption, design: .default)
    }
    
    static var caption2: Font {
        .system(.caption2, design: .default)
    }
    
    // MARK: - Custom Fonts (Rounded Design)
    
    static var roundedBody: Font {
        .system(.body, design: .rounded)
    }
    
    static var roundedHeadline: Font {
        .system(.headline, design: .rounded)
    }
}
