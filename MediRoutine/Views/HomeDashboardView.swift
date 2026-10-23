import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingNotificationsSheet = false
    @State private var showingTakeNowAlert = false
    @State private var takenDoseName = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Top Header: User Profile Greeting & Notification Bell
                HStack(alignment: .center) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(store.greeting()),")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text(store.userName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(store.tr("Stay healthy, stay happy!"))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
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
                                .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 42, height: 42)
                            
                            if store.unreadNotificationsCount > 0 {
                                Circle()
                                    .fill(AppTheme.primaryRed)
                                    .frame(width: 10, height: 10)
                                    .offset(x: -2, y: 4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Next Medicine Hero Card
                if let next = store.nextMedicine() {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "pill.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(store.tr("Next Medicine"))
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    Text(next.medicineName)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(next.doseDescription)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            HStack(spacing: 5) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 13))
                                Text(next.timeString)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                store.toggleDoseTaken(doseId: next.id)
                                takenDoseName = next.medicineName
                                showingTakeNowAlert = true
                            }) {
                                Text(next.isTaken ? "Taken ✓" : store.tr("Take Now"))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(next.isTaken ? Color.black.opacity(0.7) : AppTheme.primaryRed)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(AppTheme.heroRedGradient)
                            .shadow(color: AppTheme.primaryRed.opacity(0.35), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal)
                }
                
                // 4 Quick Actions (Health Tracker, Family Sync, Reports, Emergency)
                HStack(spacing: 12) {
                    // Health Tracker
                    QuickActionCard(
                        title: store.tr("Health Tracker"),
                        systemImage: "heart.fill",
                        tintColor: Color(red: 244/255, green: 63/255, blue: 94/255),
                        backgroundColor: Color(red: 255/255, green: 241/255, blue: 242/255)
                    ) {
                        store.selectedTab = 2 // Direct to Health Tracker tab
                    }
                    
                    // Family Sync
                    QuickActionCard(
                        title: store.tr("Family Sync"),
                        systemImage: "person.2.fill",
                        tintColor: Color(red: 14/255, green: 165/255, blue: 233/255),
                        backgroundColor: Color(red: 240/255, green: 249/255, blue: 255/255)
                    ) {
                        store.selectedTab = 3 // Family Sync tab
                    }
                    
                    // Reports
                    QuickActionCard(
                        title: store.tr("Reports"),
                        systemImage: "chart.bar.fill",
                        tintColor: Color(red: 139/255, green: 92/255, blue: 246/255),
                        backgroundColor: Color(red: 245/255, green: 243/255, blue: 255/255)
                    ) {
                        store.selectedTab = 4 // Reports / more tab
                    }
                    
                    // Emergency
                    QuickActionCard(
                        title: store.tr("Emergency"),
                        systemImage: "cross.case.fill",
                        tintColor: Color(red: 239/255, green: 68/255, blue: 68/255),
                        backgroundColor: Color(red: 254/255, green: 242/255, blue: 242/255)
                    ) {
                        store.showingSOSSheet = true
                    }
                }
                .padding(.horizontal)
                
                // Today's Schedule Section
                VStack(spacing: 14) {
                    HStack {
                        Text(store.tr("Today's Schedule"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            store.selectedTab = 1 // Go to Schedule tab
                        }) {
                            Text(store.tr("View All"))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.primaryRed)
                        }
                    }
                    
                    // List of today's doses
                    VStack(spacing: 12) {
                        ForEach(store.todaySchedule) { dose in
                            DoseRowCard(dose: dose) {
                                store.toggleDoseTaken(doseId: dose.id)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 6)
                
                // Bottom spacing for custom tab bar
                Spacer()
                    .frame(height: 90)
            }
        }
        .sheet(isPresented: $showingNotificationsSheet) {
            NotificationsSheetView()
                .environmentObject(store)
        }
        .alert(isPresented: $showingTakeNowAlert) {
            Alert(
                title: Text("Dose Recorded"),
                message: Text("Great job taking \(takenDoseName)! Your adherence score has been updated."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Quick Action Card Component
struct QuickActionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let systemImage: String
    let tintColor: Color
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? tintColor.opacity(0.18) : backgroundColor)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .foregroundColor(tintColor)
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .modernCard(cornerRadius: 16)
        }
    }
}

// MARK: - Dose Row Card
struct DoseRowCard: View {
    @Environment(\.colorScheme) var colorScheme
    let dose: ScheduledDose
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Time Pill indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(dose.isTaken ? AppTheme.successGreen : AppTheme.primaryRed)
                    .frame(width: 6, height: 6)
                
                Text(dose.timeString)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(width: 78, alignment: .leading)
            
            // Medicine details
            VStack(alignment: .leading, spacing: 3) {
                Text(dose.medicineName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .strikethrough(dose.isTaken, color: .secondary)
                
                Text(dose.doseDescription)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Checkmark button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(dose.isTaken ? AppTheme.successGreen : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if dose.isTaken {
                        Circle()
                            .fill(AppTheme.successGreen)
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .modernCard(cornerRadius: 16)
    }
}

// MARK: - Notifications Sheet
struct NotificationsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent Alerts")) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(AppTheme.primaryRed)
                        VStack(alignment: .leading) {
                            Text("Dose Reminder: Vitamin D3")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Scheduled for 12:30 PM • 1 capsule after food")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(Color.blue)
                        VStack(alignment: .leading) {
                            Text("Weekly Report Ready")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Your adherence rate was 92% this week (+5%)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
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
                }
            }
        }
    }
}
