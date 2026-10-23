import SwiftUI

struct SplashScreenView: View {
    @State private var pulseHeart = false
    @State private var scaleLogo = false
    @State private var opacityText = false
    @Binding var isFinished: Bool
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 245/255, blue: 247/255)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Medi Routine Shield Icon
                ZStack {
                    // Pulsing background rings
                    Circle()
                        .fill(AppTheme.primaryRed.opacity(0.12))
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseHeart ? 1.25 : 0.95)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulseHeart)
                    
                    Circle()
                        .fill(AppTheme.primaryRed.opacity(0.2))
                        .frame(width: 125, height: 125)
                    
                    // Red Rounded Shield
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(AppTheme.heroRedGradient)
                        .frame(width: 90, height: 90)
                        .shadow(color: AppTheme.primaryRed.opacity(0.4), radius: 15, x: 0, y: 8)
                        .overlay(
                            // ECG Heartbeat line + pill icon
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(pulseHeart ? 1.1 : 0.9)
                                .animation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true), value: pulseHeart)
                        )
                }
                .scaleEffect(scaleLogo ? 1.0 : 0.6)
                
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Medi")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 20/255, green: 25/255, blue: 35/255))
                        Text("Routine")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.primaryRed)
                    }
                    
                    Text("Your Health • Our Priority")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Healthy Today • Happier Tomorrow")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.primaryRed.opacity(0.85))
                        .padding(.top, 4)
                }
                .opacity(opacityText ? 1.0 : 0.0)
                .offset(y: opacityText ? 0 : 15)
                
                Spacer()
                
                // Bottom loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryRed))
                    .scaleEffect(1.2)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            pulseHeart = true
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                scaleLogo = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                opacityText = true
            }
            
            // Auto-advance after 1.8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isFinished = true
                }
            }
        }
    }
}
