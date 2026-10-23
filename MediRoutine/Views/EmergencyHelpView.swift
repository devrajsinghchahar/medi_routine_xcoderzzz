import SwiftUI
import CoreLocation

struct EmergencyHelpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    @ObservedObject var locationService = LocationService.shared
    
    @State private var isPulsing = false
    @State private var showingCallAlert = false
    @State private var selectedEmergencyNumber = "112"
    @State private var showingMedicalInfoSheet = false
    @State private var locationSharedAlert = false
    
    // 5-second cancelable SOS Countdown HUD
    @State private var isCountingDown = false
    @State private var countdownRemaining = 5
    @State private var countdownTimer: Timer? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                (store.isDarkMode ? AppTheme.screenBackgroundDark : Color(red: 247/255, green: 249/255, blue: 254/255))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerBanner
                        sosBeaconSection
                        gpsTelemetryCard
                        emergencyActionCards
                        contactsSection
                        Spacer().frame(height: 50)
                    }
                }
                
                if isCountingDown {
                    countdownOverlay
                }
            }
            .navigationTitle(store.tr("Emergency Help"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            .onAppear {
                isPulsing = true
                locationService.requestPermissionAndLocate()
            }
            .alert("Call \(selectedEmergencyNumber)?", isPresented: $showingCallAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Call Now", role: .destructive) {
                    let cleaned = selectedEmergencyNumber.replacingOccurrences(of: " ", with: "")
                    if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("This will immediately place a phone call to emergency dispatch or your designated contact.")
            }
            .alert("Location Dispatched", isPresented: $locationSharedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your live GPS coordinates (\(locationService.formattedCoordinates)) and emergency health profile were composed for instant sharing.")
            }
            .sheet(isPresented: $showingMedicalInfoSheet) {
                MedicalInfoSheetView()
                    .environmentObject(store)
            }
        }
    }
    
    // MARK: - Subviews
    private var headerBanner: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isPulsing ? 1.3 : 0.8)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                
                Text("EMERGENCY RESPONSE PROTOCOL")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color.red)
            }
            
            Text(store.tr("When every second counts"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 6)
    }
    
    private var sosBeaconSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer Radar Waves
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.red.opacity(0.18 - Double(i) * 0.05), lineWidth: 2)
                        .frame(width: 170 + CGFloat(i * 45), height: 170 + CGFloat(i * 45))
                        .scaleEffect(isPulsing ? 1.15 : 0.92)
                        .animation(
                            .easeInOut(duration: 1.1 + Double(i) * 0.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }
                
                // Ambient Glow Circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.red.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                // Main SOS Button
                Button(action: startSOSCountdown) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.sosPulsingGradient)
                            .frame(width: 136, height: 136)
                            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 2))
                            .shadow(color: Color.red.opacity(0.6), radius: 20, x: 0, y: 8)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("SOS")
                                .font(.system(size: 38, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 220)
            
            Text(store.tr("Tap for immediate help"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
    
    private var gpsTelemetryCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.cyberCyan.opacity(0.18))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "location.fill.viewfinder")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.cyberCyan)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("LIVE GPS TELEMETRY")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundColor(AppTheme.cyberCyan)
                
                Text(locationService.addressString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(locationService.formattedCoordinates)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                locationService.startUpdating()
                HapticManager.shared.impact(style: .light)
            }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.cyberCyan)
                    .padding(8)
                    .background(Circle().fill(AppTheme.cyberCyan.opacity(0.12)))
            }
        }
        .padding(14)
        .futuristicCard(cornerRadius: 18, glowColor: AppTheme.cyberCyan.opacity(0.2), glowRadius: 6)
        .padding(.horizontal, 20)
    }
    
    private var emergencyActionCards: some View {
        VStack(spacing: 14) {
            // Call 112
            Button(action: {
                selectedEmergencyNumber = "112"
                showingCallAlert = true
                HapticManager.shared.impact(style: .heavy)
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.16))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "phone.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("Call Emergency"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("National Dispatch: 112 / 108")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.red)
                }
                .padding(16)
                .futuristicCard(cornerRadius: 18, glowColor: Color.red.opacity(0.2), glowRadius: 6)
            }
            
            // Share Location via SMS
            Button(action: broadcastLocationViaSMS) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.cyberCyan.opacity(0.16))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.cyberCyan)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("Share Location"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Send GPS + Medical ID via SMS")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.cyberCyan)
                }
                .padding(16)
                .futuristicCard(cornerRadius: 18, glowColor: AppTheme.cyberCyan.opacity(0.2), glowRadius: 6)
            }
            
            // Medical Info Sheet
            Button(action: {
                showingMedicalInfoSheet = true
                HapticManager.shared.impact(style: .medium)
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.quantumPurple.opacity(0.16))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "cross.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.quantumPurple)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("Medical Info"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Blood \(store.userBloodGroup) • \(store.medicines.count) Prescriptions")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .futuristicCard(cornerRadius: 18)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Emergency Contacts")
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(store.emergencyContacts.count) Active")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.neonGreen)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(store.emergencyContacts) { contact in
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(contact.name)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("\(contact.relationship) • \(contact.phone)")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedEmergencyNumber = contact.phone
                            showingCallAlert = true
                        }) {
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.neonGreen)
                                .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 6)
                        }
                    }
                    .padding(16)
                    .futuristicCard(cornerRadius: 18)
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 6)
    }
    
    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Text("DISPATCHING SOS PROTOCOL")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color.red)
                
                ZStack {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 8)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(countdownRemaining) / 5.0)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 160, height: 160)
                        .animation(.linear(duration: 1.0), value: countdownRemaining)
                    
                    Text("\(countdownRemaining)")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text("Sending live GPS coordinates & calling 112 in \(countdownRemaining) seconds...")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                HStack(spacing: 16) {
                    Button(action: cancelSOSCountdown) {
                        Text("CANCEL")
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.5))
                            )
                    }
                    
                    Button(action: triggerSOSImmediately) {
                        Text("DISPATCH NOW")
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.primaryRed)
                            )
                    }
                }
                .padding(.horizontal, 30)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Real Life SOS Methods
    private func startSOSCountdown() {
        HapticManager.shared.notification(type: .warning)
        countdownRemaining = 5
        withAnimation { isCountingDown = true }
        
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdownRemaining > 1 {
                countdownRemaining -= 1
                HapticManager.shared.impact(style: .heavy)
            } else {
                countdownTimer?.invalidate()
                triggerSOSImmediately()
            }
        }
    }
    
    private func cancelSOSCountdown() {
        countdownTimer?.invalidate()
        withAnimation { isCountingDown = false }
        HapticManager.shared.notification(type: .success)
    }
    
    private func triggerSOSImmediately() {
        countdownTimer?.invalidate()
        withAnimation { isCountingDown = false }
        HapticManager.shared.notification(type: .error)
        
        // Open phone call to 112
        if let url = URL(string: "tel://112"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        
        // Open SMS with GPS location
        broadcastLocationViaSMS()
    }
    
    private func broadcastLocationViaSMS() {
        let msg = """
        EMERGENCY SOS: I need medical assistance!
        Patient: \(store.userName) (Blood \(store.userBloodGroup))
        Location: \(locationService.addressString)
        Maps: \(locationService.appleMapsURL)
        """
        let encoded = msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:&body=\(encoded)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            locationSharedAlert = true
        }
    }
}

// MARK: - Medical Info Sheet
struct MedicalInfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Emergency Health ID").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    HStack {
                        Text("Full Name")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        Spacer()
                        Text(store.userName)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    HStack {
                        Text("Blood Group")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        Spacer()
                        Text(store.userBloodGroup)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Known Allergies")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        Spacer()
                        Text(store.userAllergies)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Emergency Notes")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        Spacer()
                        Text(store.emergencyNotes)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Active Prescriptions & Dosages").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    ForEach(store.medicines) { med in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(med.name)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                Text("\(med.doseDescription) • Stock: \(med.stockCount)")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(med.dosage)
                                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                                .foregroundColor(AppTheme.primaryRed)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Medical Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
