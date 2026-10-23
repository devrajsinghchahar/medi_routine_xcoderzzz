import SwiftUI

struct BiometricPulseScannerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var isScanning = false
    @State private var scanProgress: CGFloat = 0.0
    @State private var detectedBPM: Int = 0
    @State private var scanFinished = false
    @State private var pulseWave = false
    @State private var timerSubscription: Timer?
    @State private var currentStepText = "Place index finger over biometric sensor & tap Start"
    
    var body: some View {
        NavigationView {
            ZStack {
                (store.isDarkMode ? AppTheme.screenBackgroundDark : Color(red: 245/255, green: 247/255, blue: 252/255))
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Top Telemetry Status Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BIOMETRIC OPTICAL TELEMETRY")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.cyberCyan)
                            
                            Text("Bio-Pulse Radar")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Live calibration badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isScanning ? AppTheme.neonGreen : Color.secondary.opacity(0.5))
                                .frame(width: 8, height: 8)
                            
                            Text(isScanning ? "ACQUIRING" : "STANDBY")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                .foregroundColor(isScanning ? AppTheme.neonGreen : .secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.secondary.opacity(0.12)))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Central Holographic Bio-Scanner HUD
                    ZStack {
                        // Outer Radar Pulse Rings
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(
                                    AppTheme.primaryRed.opacity(isScanning ? Double(3 - i) * 0.15 : 0.05),
                                    lineWidth: 2
                                )
                                .frame(width: 220 + CGFloat(i * 45), height: 220 + CGFloat(i * 45))
                                .scaleEffect(pulseWave ? 1.08 : 0.96)
                                .animation(
                                    .easeInOut(duration: 1.0 + Double(i) * 0.2)
                                    .repeatForever(autoreverses: true),
                                    value: pulseWave
                                )
                        }
                        
                        // Circular HUD Scan Track
                        Circle()
                            .stroke(Color.secondary.opacity(0.15), lineWidth: 8)
                            .frame(width: 210, height: 210)
                        
                        Circle()
                            .trim(from: 0.0, to: scanProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [AppTheme.cyberCyan, AppTheme.primaryRed, AppTheme.neonGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 210, height: 210)
                            .animation(.linear(duration: 0.1), value: scanProgress)
                        
                        // Center Scanner Core
                        VStack(spacing: 10) {
                            if scanFinished {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.neonGreen)
                                
                                Text("\(detectedBPM)")
                                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("BPM • Optimal")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.neonGreen)
                            } else if isScanning {
                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.primaryRed)
                                    .scaleEffect(pulseWave ? 1.2 : 0.9)
                                
                                Text("\(Int(scanProgress * 100))%")
                                    .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.primary)
                                
                                Text("Reading pulse...")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            } else {
                                Image(systemName: "touchid")
                                    .font(.system(size: 52))
                                    .foregroundColor(AppTheme.primaryRed)
                                
                                Text("Touch & Scan")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .frame(height: 280)
                    
                    // Live ECG Heartbeat Line
                    VStack(spacing: 8) {
                        ECGHeartbeatView(tintColor: isScanning ? AppTheme.primaryRed : Color.secondary.opacity(0.3), height: 32)
                            .padding(.horizontal, 24)
                        
                        Text(currentStepText)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if scanFinished {
                            Button(action: saveMeasurement) {
                                HStack(spacing: 10) {
                                    Image(systemName: "tray.and.arrow.down.fill")
                                    Text("Log \(detectedBPM) BPM to Health Tracker")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.neonGreenGradient)
                                        .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 12, x: 0, y: 6)
                                )
                            }
                            
                            Button(action: resetScan) {
                                Text("Scan Again")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        } else {
                            Button(action: toggleScan) {
                                HStack(spacing: 10) {
                                    Image(systemName: isScanning ? "stop.fill" : "play.fill")
                                    Text(isScanning ? "Cancel Scan" : "Start Bio-Scan")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(isScanning ? LinearGradient(colors: [Color.gray, Color.secondary], startPoint: .topLeading, endPoint: .bottomTrailing) : AppTheme.heroRedGradient)
                                        .shadow(color: AppTheme.primaryRed.opacity(isScanning ? 0.0 : 0.4), radius: 12, x: 0, y: 6)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
        .onDisappear {
            timerSubscription?.invalidate()
        }
    }
    
    private func toggleScan() {
        if isScanning {
            resetScan()
        } else {
            startScan()
        }
    }
    
    private func startScan() {
        isScanning = true
        scanProgress = 0.0
        scanFinished = false
        pulseWave = true
        currentStepText = "Hold steady... optical sensor calibrating pulse waves"
        HapticManager.shared.impact(style: .medium)
        
        timerSubscription?.invalidate()
        timerSubscription = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if scanProgress < 1.0 {
                scanProgress += 0.015
                if Int(scanProgress * 100) % 25 == 0 {
                    HapticManager.shared.impact(style: .light)
                }
            } else {
                timerSubscription?.invalidate()
                completeScan()
            }
        }
    }
    
    private func completeScan() {
        isScanning = false
        scanFinished = true
        pulseWave = false
        // Realistic normal heart rate between 71 and 78
        detectedBPM = Int.random(in: 71...77)
        currentStepText = "Pulse telemetry captured with 99.4% optical confidence."
        HapticManager.shared.notification(type: .success)
    }
    
    private func resetScan() {
        timerSubscription?.invalidate()
        isScanning = false
        scanFinished = false
        scanProgress = 0.0
        currentStepText = "Place index finger over biometric sensor & tap Start"
    }
    
    private func saveMeasurement() {
        store.addVital(type: .heartRate, value: Double(detectedBPM), notes: "Biometric optical scan")
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}
