import SwiftUI

enum AppTheme {
    // Brand Colors
    static let primaryRed = Color(red: 229/255, green: 57/255, blue: 80/255)       // #E53950
    static let primaryGradientStart = Color(red: 255/255, green: 75/255, blue: 95/255)
    static let primaryGradientEnd = Color(red: 220/255, green: 40/255, blue: 65/255)
    
    static let cardBackgroundLight = Color(red: 255/255, green: 255/255, blue: 255/255)
    static let cardBackgroundDark = Color(red: 26/255, green: 34/255, blue: 48/255)
    
    static let screenBackgroundLight = Color(red: 247/255, green: 248/255, blue: 251/255)
    static let screenBackgroundDark = Color(red: 15/255, green: 22/255, blue: 34/255)
    
    static let successGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
    static let alertOrange = Color(red: 249/255, green: 115/255, blue: 22/255)
    static let infoBlue = Color(red: 14/255, green: 165/255, blue: 233/255)
    static let purpleAccent = Color(red: 139/255, green: 92/255, blue: 246/255)
    
    // Gradients
    static var heroRedGradient: LinearGradient {
        LinearGradient(
            colors: [primaryGradientStart, primaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var sosPulsingGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 255/255, green: 65/255, blue: 85/255), Color(red: 200/255, green: 20/255, blue: 40/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - View Modifiers
struct ModernCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 20
    var hasBorder: Bool = false
    var borderColor: Color = Color.clear
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(colorScheme == .dark ? AppTheme.cardBackgroundDark : AppTheme.cardBackgroundLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(hasBorder ? borderColor : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.03)), lineWidth: 1)
                    )
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            )
    }
}

extension View {
    func modernCard(cornerRadius: CGFloat = 20, hasBorder: Bool = false, borderColor: Color = Color.clear) -> some View {
        self.modifier(ModernCardModifier(cornerRadius: cornerRadius, hasBorder: hasBorder, borderColor: borderColor))
    }
}
