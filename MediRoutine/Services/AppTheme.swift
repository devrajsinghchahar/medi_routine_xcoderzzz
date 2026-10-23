import SwiftUI

enum AppTheme {
    // MARK: - Futuristic Biotech Brand Colors
    static let primaryRed = Color(red: 235/255, green: 45/255, blue: 75/255)         // #EB2D4B Cyber Crimson
    static let primaryGradientStart = Color(red: 255/255, green: 65/255, blue: 95/255)
    static let primaryGradientEnd = Color(red: 215/255, green: 30/255, blue: 60/255)
    
    // Cyber & Biotech Accents
    static let cyberCyan = Color(red: 0/255, green: 220/255, blue: 255/255)         // #00DCFF
    static let neonGreen = Color(red: 16/255, green: 220/255, blue: 130/255)        // #10DC82
    static let quantumPurple = Color(red: 168/255, green: 85/255, blue: 247/255)    // #A855F7
    static let electricAmber = Color(red: 251/255, green: 175/255, blue: 30/255)    // #FBAF1E
    
    // Backgrounds & Surface Cards
    static let cardBackgroundLight = Color.white
    static let cardBackgroundDark = Color(red: 18/255, green: 24/255, blue: 38/255)
    
    static let screenBackgroundLight = Color(red: 246/255, green: 248/255, blue: 252/255)
    static let screenBackgroundDark = Color(red: 10/255, green: 14/255, blue: 24/255)
    
    static let successGreen = Color(red: 16/255, green: 198/255, blue: 110/255)
    static let alertOrange = Color(red: 249/255, green: 115/255, blue: 22/255)
    static let infoBlue = Color(red: 14/255, green: 165/255, blue: 233/255)
    
    // MARK: - Futuristic Gradients
    static var heroRedGradient: LinearGradient {
        LinearGradient(
            colors: [primaryGradientStart, primaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cyberCyanGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0/255, green: 210/255, blue: 255/255), Color(red: 0/255, green: 140/255, blue: 255/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var neonGreenGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 20/255, green: 230/255, blue: 140/255), Color(red: 5/255, green: 180/255, blue: 100/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var quantumPurpleGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 180/255, green: 90/255, blue: 255/255), Color(red: 120/255, green: 40/255, blue: 230/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var sosPulsingGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 255/255, green: 50/255, blue: 75/255), Color(red: 195/255, green: 15/255, blue: 35/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Hex Color Support
extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Futuristic Card View Modifier
struct FuturisticCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 22
    var glowColor: Color = Color.clear
    var glowRadius: CGFloat = 0
    var hasCyberBorder: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        colorScheme == .dark
                            ? LinearGradient(
                                colors: [
                                    Color(red: 22/255, green: 30/255, blue: 48/255),
                                    Color(red: 16/255, green: 22/255, blue: 36/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white, Color(red: 250/255, green: 252/255, blue: 255/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                colorScheme == .dark
                                    ? LinearGradient(
                                        colors: [
                                            glowColor != Color.clear ? glowColor.opacity(0.4) : Color.white.opacity(0.12),
                                            Color.white.opacity(0.04)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [
                                            glowColor != Color.clear ? glowColor.opacity(0.3) : Color.black.opacity(0.06),
                                            Color.black.opacity(0.02)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(
                        color: glowColor != Color.clear
                            ? glowColor.opacity(colorScheme == .dark ? 0.35 : 0.2)
                            : (colorScheme == .dark ? Color.black.opacity(0.45) : Color.black.opacity(0.05)),
                        radius: glowRadius > 0 ? glowRadius : 10,
                        x: 0,
                        y: 4
                    )
            )
    }
}

// MARK: - Animated Hologram Shimmer View Modifier
struct HologramShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0
    var isActive: Bool = true
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.18),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(25))
                        .offset(x: phase * geo.size.width * 2)
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Animated ECG Waveform
struct ECGHeartbeatView: View {
    var tintColor: Color = AppTheme.primaryRed
    var height: CGFloat = 28
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Dim ghost wave
                ECGShape()
                    .stroke(tintColor.opacity(0.2), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: geo.size.width, height: height)
                
                // Active glowing pulse wave
                ECGShape()
                    .trim(from: max(0, progress - 0.35), to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [tintColor.opacity(0.1), tintColor, Color.white],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: tintColor.opacity(0.8), radius: 4, x: 0, y: 0)
                    .frame(width: geo.size.width, height: height)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                progress = 1.35
            }
        }
    }
}

struct ECGShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midY = h / 2.0
        
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: w * 0.18, y: midY))
        path.addLine(to: CGPoint(x: w * 0.22, y: midY - h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.26, y: midY + h * 0.1))
        path.addLine(to: CGPoint(x: w * 0.30, y: midY))
        path.addLine(to: CGPoint(x: w * 0.40, y: midY))
        // QRS complex
        path.addLine(to: CGPoint(x: w * 0.44, y: midY + h * 0.25)) // Q
        path.addLine(to: CGPoint(x: w * 0.50, y: midY - h * 0.48)) // R peak
        path.addLine(to: CGPoint(x: w * 0.55, y: midY + h * 0.35)) // S
        path.addLine(to: CGPoint(x: w * 0.58, y: midY))
        path.addLine(to: CGPoint(x: w * 0.68, y: midY))
        // T wave
        path.addLine(to: CGPoint(x: w * 0.74, y: midY - h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.80, y: midY))
        path.addLine(to: CGPoint(x: w, y: midY))
        
        return path
    }
}

extension View {
    func modernCard(cornerRadius: CGFloat = 20, hasBorder: Bool = false, borderColor: Color = Color.clear) -> some View {
        self.modifier(FuturisticCardModifier(cornerRadius: cornerRadius, glowColor: borderColor, glowRadius: hasBorder ? 6 : 0, hasCyberBorder: hasBorder))
    }
    
    func futuristicCard(cornerRadius: CGFloat = 22, glowColor: Color = Color.clear, glowRadius: CGFloat = 0) -> some View {
        self.modifier(FuturisticCardModifier(cornerRadius: cornerRadius, glowColor: glowColor, glowRadius: glowRadius))
    }
    
    func hologramShimmer(active: Bool = true) -> some View {
        self.modifier(HologramShimmerModifier(isActive: active))
    }
}
