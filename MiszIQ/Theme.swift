import SwiftUI

// MARK: - App Theme Colors
extension Color {
    // Primary Colors
    static let royalBlue = Color(red: 65/255, green: 105/255, blue: 225/255)
    static let turquoise = Color(red: 64/255, green: 224/255, blue: 208/255)

    // Lighter variants for backgrounds
    static let royalBlueLight = Color(red: 65/255, green: 105/255, blue: 225/255).opacity(0.12)
    static let turquoiseLight = Color(red: 64/255, green: 224/255, blue: 208/255).opacity(0.12)

    // Theme accent (primary app color)
    static let appAccent = royalBlue
    static let appSecondary = turquoise
}

// MARK: - Theme Helper
struct AppTheme {
    // Unified accent color for all categories and games
    static let accent = Color.royalBlue
    static let secondary = Color.turquoise

    // Performance bracket colors (using theme colors instead of rainbow)
    static func bracketColor(for percentile: Int) -> Color {
        if percentile >= 90 {
            return .turquoise  // Top performers
        } else if percentile >= 70 {
            return .royalBlue  // High performers
        } else if percentile >= 50 {
            return Color(red: 64/255, green: 164/255, blue: 216/255)  // Mid-range (blend)
        } else {
            return .royalBlue.opacity(0.7)  // Developing
        }
    }
}
