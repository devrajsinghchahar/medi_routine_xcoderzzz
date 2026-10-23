import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingNotificationsSheet = false
    @State private var showingTakeNowAlert = false
    @State private var takenDoseName = ""
    @State private var pulseHeroHalo = false
    @State private var filterStatus: Int = 0 // 0: All, 1: Pending, 2: Taken
    @State private var showingRefillSheet = false
    @State private var selectedMedForRefill: Medicine?
    
    var filteredDoses: [ScheduledDose] {
        switch filterStatus {
        case 1:
            return store.todaySchedule.filter { !$0.isTaken }
        case 2:
            return store.todaySchedule.filter { $0.isTaken }
        default:
            return store.todaySchedule
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // MARK: - Futuristic Top Header & Bio-Telemetry
                HStack(alignment: .center) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.primaryRed, AppTheme.quantumPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 54, height: 54)
                                .shadow(color: AppTheme.primaryRed.opacity(0.35), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("\(store.greeting()),")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                // Futuristic live status dot
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(AppTheme.neonGreen)
                                        .frame(width: 6, height: 6)
                                    Text("SYNCED")
                                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                        .foregroundColor(AppTheme.neonGreen)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(AppTheme.neonGreen.opacity(0.12)))
                            }
                            
                            Text(store.userName)
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(store.tr("Stay healthy, stay happy!"))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Notification Bell Button
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        showingNotificationsSheet = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(store.isDarkMode ? Color(red: 24/255, green: 32/255, blue: 50/255) : Color.white)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1.2)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                            
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.primaryRed)
                                .frame(width: 48, height: 48)
                            
                            if store.unreadNotificationsCount > 0 {
                                Text("\(store.unreadNotificationsCount)")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(AppTheme.primaryRed))
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // MARK: - Animated Live Heartbeat ECG Banner
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryRed)
                        
                        Text("VITAL TELEMETRY")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(AppTheme.primaryRed)
                    }
                    
                    ECGHeartbeatView(tintColor: AppTheme.primaryRed, height: 24)
                    
                    if let hr = store.latestVital(for: .heartRate) {
                        Text("\(Int(hr.value)) BPM")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(store.isDarkMode ? Color(red: 20/255, green: 28/255, blue: 44/255) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppTheme.primaryRed.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // MARK: - Hero "Next Medicine" Card
                if let next = store.nextMedicine(), !store.todaySchedule.allSatisfy({ $0.isTaken }) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.18))
                                        .frame(width: 56, height: 56)
                                        .scaleEffect(pulseHeroHalo ? 1.15 : 0.95)
                                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseHeroHalo)
                                    
                                    Image(systemName: "pill.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(pulseHeroHalo ? 12 : -12))
                                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseHeroHalo)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(store.tr("Next Medicine").uppercased())
                                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        Text("• \(next.assignedMemberName)")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Text(next.medicineName)
                                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(next.doseDescription)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.92))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.25))
                        
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 15))
                                Text(next.timeString)
                                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                store.toggleDoseTaken(doseId: next.id)
                                takenDoseName = next.medicineName
                                showingTakeNowAlert = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                    Text(store.tr("Take Now"))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(AppTheme.primaryRed)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(AppTheme.heroRedGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
                            )
                            .shadow(color: AppTheme.primaryRed.opacity(0.4), radius: 16, x: 0, y: 8)
                    )
                    .hologramShimmer()
                    .padding(.horizontal, 20)
                    .onAppear { pulseHeroHalo = true }
                } else {
                    // Celebration All Taken Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.neonGreen.opacity(0.2))
                                .frame(width: 58, height: 58)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.neonGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("All Doses Completed!")
                                .font(.system(size: 19, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("100% adherence score achieved for today.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(18)
                    .futuristicCard(cornerRadius: 22, glowColor: AppTheme.neonGreen, glowRadius: 10)
                    .padding(.horizontal, 20)
                }
                
                // MARK: - 4 Futuristic Quick Actions
                HStack(spacing: 12) {
                    FuturisticQuickActionCard(
                        title: store.tr("Health Tracker"),
                        subtitle: "Live Vitals",
                        systemImage: "heart.text.square.fill",
                        accentColor: AppTheme.primaryRed
                    ) {
                        store.selectedTab = 2
                    }
                    
                    FuturisticQuickActionCard(
                        title: store.tr("Family Sync"),
                        subtitle: "\(store.familyMembers.count) Synced",
                        systemImage: "person.2.circle.fill",
                        accentColor: AppTheme.cyberCyan
                    ) {
                        store.selectedTab = 3
                    }
                    
                    FuturisticQuickActionCard(
                        title: store.tr("Reports"),
                        subtitle: "\(Int(store.overallAdherencePercentage()))% Rate",
                        systemImage: "chart.xyaxis.line",
                        accentColor: AppTheme.quantumPurple
                    ) {
                        store.selectedTab = 4
                    }
                    
                    FuturisticQuickActionCard(
                        title: store.tr("Emergency"),
                        subtitle: "SOS 112",
                        systemImage: "cross.circle.fill",
                        accentColor: Color.red
                    ) {
                        store.showingSOSSheet = true
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - Interactive Bio-Pulse Scanner Card
                Button(action: {
                    store.showingPulseScanner = true
                }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.cyberCyan.opacity(0.18))
                                .frame(width: 46, height: 46)
                            
                            Image(systemName: "touchid")
                                .font(.system(size: 26))
                                .foregroundColor(AppTheme.cyberCyan)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("BIOMETRIC SCANNER")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                    .foregroundColor(AppTheme.cyberCyan)
                                
                                Text("• INSTANT READ")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppTheme.neonGreen)
                            }
                            
                            Text("Measure Heart Rate with Pulse Radar")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .futuristicCard(cornerRadius: 18, glowColor: AppTheme.cyberCyan, glowRadius: 6)
                }
                .padding(.horizontal, 20)
                
                // MARK: - Today's Schedule Section
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.tr("Today's Schedule"))
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("\(store.todaySchedule.filter { $0.isTaken }.count) of \(store.todaySchedule.count) completed")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            store.markAllDosesTaken()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.done")
                                Text("Take All")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.neonGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(AppTheme.neonGreen.opacity(0.14)))
                        }
                    }
                    
                    // Filter Chips: All, Pending, Taken
                    HStack(spacing: 10) {
                        ForEach(["All", "Pending", "Taken"].indices, id: \.self) { idx in
                            let titles = ["All", "Pending", "Taken"]
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    filterStatus = idx
                                }
                                HapticManager.shared.impact(style: .light)
                            }) {
                                Text(titles[idx])
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(filterStatus == idx ? AppTheme.primaryRed : Color.secondary.opacity(0.12))
                                    )
                                    .foregroundColor(filterStatus == idx ? .white : .primary)
                            }
                        }
                        Spacer()
                    }
                    
                    // List of today's doses
                    VStack(spacing: 14) {
                        if filteredDoses.isEmpty {
                            Text("No medications match this filter.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(filteredDoses) { dose in
                                FuturisticDoseRowCard(dose: dose) {
                                    store.toggleDoseTaken(doseId: dose.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                
                // Bottom spacing for floating tab bar
                Spacer()
                    .frame(height: 100)
            }
        }
        .sheet(isPresented: $showingNotificationsSheet) {
            NotificationsSheetView()
                .environmentObject(store)
        }
        .sheet(isPresented: $store.showingPulseScanner) {
            BiometricPulseScannerView()
                .environmentObject(store)
        }
        .alert(isPresented: $showingTakeNowAlert) {
            Alert(
                title: Text("Dose Recorded"),
                message: Text("Great job taking \(takenDoseName)! Inventory adjusted and adherence score updated."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Futuristic Quick Action Card Component
struct FuturisticQuickActionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let subtitle: String
    let systemImage: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(accentColor.opacity(colorScheme == .dark ? 0.22 : 0.12))
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(accentColor.opacity(0.35), lineWidth: 1)
                        )
                    
                    Image(systemName: systemImage)
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(accentColor)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .futuristicCard(cornerRadius: 18)
        }
    }
}

// MARK: - Futuristic Dose Row Card
struct FuturisticDoseRowCard: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.colorScheme) var colorScheme
    let dose: ScheduledDose
    let onToggle: () -> Void
    
    var associatedMedicine: Medicine? {
        store.medicines.first(where: { $0.id == dose.medicineId })
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Time Capsule with Live Indicator
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(dose.isTaken ? AppTheme.neonGreen : AppTheme.primaryRed)
                        .frame(width: 7, height: 7)
                    
                    Text(dose.timeString)
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundColor(.primary)
                }
                
                Text(dose.assignedMemberName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(width: 90, alignment: .leading)
            
            // Medicine Details & Stock Level
            VStack(alignment: .leading, spacing: 4) {
                Text(dose.medicineName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .strikethrough(dose.isTaken, color: .secondary)
                
                HStack(spacing: 8) {
                    Text(dose.doseDescription)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if let med = associatedMedicine {
                        Text("\(med.stockCount) left")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(med.isLowStock ? AppTheme.alertOrange : AppTheme.neonGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(med.isLowStock ? AppTheme.alertOrange.opacity(0.15) : AppTheme.neonGreen.opacity(0.12))
                            )
                    }
                }
            }
            
            Spacer()
            
            // Interactive Glowing Checkmark Button
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    onToggle()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(
                            dose.isTaken ? AppTheme.neonGreen : Color.secondary.opacity(0.3),
                            lineWidth: 2.5
                        )
                        .frame(width: 34, height: 34)
                    
                    if dose.isTaken {
                        Circle()
                            .fill(AppTheme.neonGreen)
                            .frame(width: 34, height: 34)
                            .shadow(color: AppTheme.neonGreen.opacity(0.5), radius: 6, x: 0, y: 0)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .futuristicCard(cornerRadius: 18, glowColor: dose.isTaken ? AppTheme.neonGreen.opacity(0.2) : Color.clear)
        .contextMenu {
            if let med = associatedMedicine {
                Button(action: {
                    store.refillMedicine(medicineId: med.id, amount: 30)
                }) {
                    Label("Refill Stock (+30 pills)", systemImage: "plus.circle.fill")
                }
            }
            
            Button(role: .destructive, action: {
                store.deleteMedicine(id: dose.medicineId)
            }) {
                Label("Delete Medicine", systemImage: "trash.fill")
            }
        }
    }
}

// MARK: - Notifications Sheet
struct NotificationsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Live Bio-Alerts").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(AppTheme.primaryRed.opacity(0.15)).frame(width: 40, height: 40)
                            Image(systemName: "bell.badge.fill").foregroundColor(AppTheme.primaryRed)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Dose Reminder: Vitamin D3")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Text("Scheduled for 12:30 PM • 1 capsule after food")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.blue.opacity(0.15)).frame(width: 40, height: 40)
                            Image(systemName: "chart.xyaxis.line").foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Weekly Adherence Report Ready")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Text("Overall adherence rate: \(Int(store.overallAdherencePercentage()))% across all 4 family members")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.unreadNotificationsCount = 0
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
