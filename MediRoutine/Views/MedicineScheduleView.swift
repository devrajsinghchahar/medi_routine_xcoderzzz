import SwiftUI

struct MedicineScheduleView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedDayIndex: Int = 0
    let days = ["Today", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr("Medicine Schedule"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(store.tr("Never miss a dose"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Day Selector Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<days.count, id: \.self) { index in
                            Button(action: {
                                selectedDayIndex = index
                                HapticManager.shared.impact(style: .light)
                            }) {
                                Text(days[index])
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedDayIndex == index ? AppTheme.primaryRed : (store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white))
                                    )
                                    .foregroundColor(selectedDayIndex == index ? .white : .primary)
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedDayIndex == index ? Color.clear : Color.secondary.opacity(0.15), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(selectedDayIndex == index ? 0.1 : 0.02), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Selected Date Subtitle
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(AppTheme.primaryRed)
                    Text("Tue, 14 Oct 2025")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
                
                // Doses List
                VStack(spacing: 12) {
                    ForEach(store.todaySchedule) { dose in
                        DoseRowCard(dose: dose) {
                            store.toggleDoseTaken(doseId: dose.id)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Yellow Custom Reminder Promo Banner
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 254/255, green: 243/255, blue: 199/255))
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 217/255, green: 119/255, blue: 6/255))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Set custom reminder for any medicine."))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Add custom timing, refill alerts and notes")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(store.isDarkMode ? Color(red: 35/255, green: 30/255, blue: 20/255) : Color(red: 255/255, green: 251/255, blue: 235/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 251/255, green: 191/255, blue: 36/255).opacity(0.4), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                
                // Big Pink/Crimson "+ Add Medicine" button
                Button(action: {
                    store.showingAddMedicineSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text(store.tr("+ Add Medicine"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppTheme.heroRedGradient)
                            .shadow(color: AppTheme.primaryRed.opacity(0.35), radius: 10, x: 0, y: 5)
                    )
                }
                .padding(.horizontal)
                .padding(.top, 6)
                
                Spacer()
                    .frame(height: 100)
            }
        }
    }
}
