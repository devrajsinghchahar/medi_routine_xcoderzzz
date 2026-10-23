import SwiftUI

struct FamilyMemberProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    @State var member: FamilyMember
    @State private var selectedTab: Int = 0 // 0: Health Info, 1: Medications
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header Avatar & Identity
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.pink.opacity(0.8), Color.orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(member.displayNameWithRelation)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(member.subtitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Medication badge
                    HStack(spacing: 6) {
                        Image(systemName: "pills.fill")
                            .font(.system(size: 11))
                        Text("\(member.medicationsCount) Medications")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.primaryRed)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(AppTheme.primaryRed.opacity(0.12))
                    )
                }
                .padding(.top, 10)
                
                // Segmented control: Health Info vs Medications
                Picker("", selection: $selectedTab) {
                    Text("Health Info").tag(0)
                    Text("Medications").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == 0 {
                    // Health Info Rows
                    VStack(spacing: 12) {
                        ProfileVitalRow(
                            title: "Blood Pressure",
                            value: "118/76 mmHg",
                            status: "Normal",
                            iconName: "gauge.with.needle.fill",
                            color: Color(red: 225/255, green: 29/255, blue: 72/255)
                        )
                        
                        ProfileVitalRow(
                            title: "Heart Rate",
                            value: "76 bpm",
                            status: "Normal",
                            iconName: "heart.fill",
                            color: Color(red: 239/255, green: 68/255, blue: 68/255)
                        )
                        
                        ProfileVitalRow(
                            title: "Blood Sugar",
                            value: "95 mg/dL",
                            status: "Normal",
                            iconName: "drop.fill",
                            color: Color(red: 14/255, green: 165/255, blue: 233/255)
                        )
                        
                        // Notes
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "note.text")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 16))
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Notes")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                Text(member.notes.isEmpty ? "No special notes" : member.notes)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                        .modernCard(cornerRadius: 16)
                    }
                    .padding(.horizontal)
                } else {
                    // Medications List
                    VStack(spacing: 12) {
                        ForEach(store.medicines) { med in
                            HStack {
                                Image(systemName: med.form.iconName)
                                    .foregroundColor(AppTheme.primaryRed)
                                    .font(.title2)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(med.name)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                    Text(med.doseDescription)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(med.stockCount) left")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(med.stockCount < med.refillThreshold ? .red : .secondary)
                            }
                            .padding(14)
                            .modernCard(cornerRadius: 16)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Edit Profile Button
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.heroRedGradient)
                                .shadow(color: AppTheme.primaryRed.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditFamilyMemberSheet(member: $member)
        }
    }
}

struct ProfileVitalRow: View {
    let title: String
    let value: String
    let status: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(status)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.successGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule().fill(AppTheme.successGreen.opacity(0.12))
                )
        }
        .padding(14)
        .modernCard(cornerRadius: 16)
    }
}

struct EditFamilyMemberSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var member: FamilyMember
    @State private var name: String = ""
    @State private var condition: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Information")) {
                    TextField("Name", text: $name)
                    TextField("Primary Condition", text: $condition)
                    TextField("Medical Notes", text: $notes)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = member.name
                condition = member.primaryCondition
                notes = member.notes
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        member.name = name
                        member.primaryCondition = condition
                        member.notes = notes
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
