import SwiftUI

struct MedicineScheduleView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedDayIndex: Int = 0
    @State private var selectedMemberFilter: String = "All"
    @State private var searchText: String = ""
    
    let days = ["Today", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var formattedSelectedDate: String {
        let cal = Calendar.current
        let today = Date()
        let offset = selectedDayIndex == 0 ? 0 : (selectedDayIndex - 1)
        let targetDate = cal.date(byAdding: .day, value: offset, to: today) ?? today
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: targetDate)
    }
    
    var filteredSchedule: [ScheduledDose] {
        return store.todaySchedule.filter { dose in
            let matchesMember = (selectedMemberFilter == "All" || dose.assignedMemberName == selectedMemberFilter)
            let matchesSearch = searchText.isEmpty ||
                dose.medicineName.localizedCaseInsensitiveContains(searchText) ||
                dose.doseDescription.localizedCaseInsensitiveContains(searchText)
            return matchesMember && matchesSearch
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(store.tr("Medicine Schedule"))
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            // Futuristic active telemetry pulse
                            Circle()
                                .fill(AppTheme.cyberCyan)
                                .frame(width: 8, height: 8)
                                .shadow(color: AppTheme.cyberCyan, radius: 4)
                        }
                        
                        Text(store.tr("Never miss a dose"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick Take All button
                    Button(action: {
                        store.markAllDosesTaken()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Take All")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.neonGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(AppTheme.neonGreen.opacity(0.14)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // MARK: - Futuristic Live Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.cyberCyan)
                    
                    TextField("Search medicine, dosage or condition...", text: $searchText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(store.isDarkMode ? Color(red: 22/255, green: 30/255, blue: 48/255) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(searchText.isEmpty ? Color.secondary.opacity(0.12) : AppTheme.cyberCyan, lineWidth: 1.2)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                
                // MARK: - Day Selector Scroll Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<days.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    selectedDayIndex = index
                                }
                                HapticManager.shared.impact(style: .light)
                            }) {
                                Text(days[index])
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(selectedDayIndex == index ? AppTheme.primaryRed : (store.isDarkMode ? Color(red: 22/255, green: 30/255, blue: 48/255) : Color.white))
                                    )
                                    .foregroundColor(selectedDayIndex == index ? .white : .primary)
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedDayIndex == index ? Color.clear : Color.secondary.opacity(0.15), lineWidth: 1)
                                    )
                                    .shadow(color: selectedDayIndex == index ? AppTheme.primaryRed.opacity(0.35) : Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // MARK: - Family Member Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["All"] + store.familyMembers.map { $0.name }, id: \.self) { member in
                            Button(action: {
                                withAnimation(.spring()) { selectedMemberFilter = member }
                                HapticManager.shared.impact(style: .light)
                            }) {
                                HStack(spacing: 5) {
                                    if member != "All" {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 12))
                                    }
                                    Text(member)
                                }
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedMemberFilter == member ? AppTheme.cyberCyan.opacity(0.2) : Color.secondary.opacity(0.1))
                                )
                                .foregroundColor(selectedMemberFilter == member ? AppTheme.cyberCyan : .secondary)
                                .overlay(
                                    Capsule()
                                        .stroke(selectedMemberFilter == member ? AppTheme.cyberCyan : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // MARK: - Selected Date Telemetry Subtitle
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.primaryRed)
                    
                    Text(formattedSelectedDate)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(filteredSchedule.count) scheduled")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                
                // MARK: - Doses List
                VStack(spacing: 14) {
                    if filteredSchedule.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "pills")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No medications match your filter.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 36)
                    } else {
                        ForEach(filteredSchedule) { dose in
                            FuturisticDoseRowCard(dose: dose) {
                                store.toggleDoseTaken(doseId: dose.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - Custom Reminder Promo Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 254/255, green: 243/255, blue: 199/255))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 217/255, green: 119/255, blue: 6/255))
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("Set custom reminder for any medicine."))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Add custom timing, refill alerts and stock warnings")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(store.isDarkMode ? Color(red: 35/255, green: 30/255, blue: 20/255) : Color(red: 255/255, green: 251/255, blue: 235/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(red: 251/255, green: 191/255, blue: 36/255).opacity(0.4), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // MARK: - Big Pink/Crimson "+ Add Medicine" Button
                Button(action: {
                    store.showingAddMedicineSheet = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text(store.tr("+ Add Medicine"))
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppTheme.heroRedGradient)
                            .shadow(color: AppTheme.primaryRed.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .sheet(isPresented: $store.showingAddMedicineSheet) {
            AddMedicineView()
                .environmentObject(store)
        }
    }
}
