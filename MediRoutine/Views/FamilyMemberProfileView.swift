import SwiftUI

struct FamilyMemberProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    @State var member: FamilyMember
    @State private var selectedTab: Int = 0 // 0: Health Info, 1: Medications
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // MARK: - Header Avatar & Identity
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.pink.opacity(0.85), Color.orange.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.pink.opacity(0.35), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: member.avatarSystemName)
                            .font(.system(size: 46))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(member.displayNameWithRelation)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(member.subtitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if !member.phoneNumber.isEmpty {
                            Text(member.phoneNumber)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(AppTheme.cyberCyan)
                        }
                    }
                    
                    // Quick Calling & Messaging Action Bar
                    HStack(spacing: 16) {
                        // Call
                        Button(action: {
                            let cleaned = member.phoneNumber.replacingOccurrences(of: " ", with: "")
                            if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "phone.fill")
                                Text("Call")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(AppTheme.neonGreen))
                            .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        
                        // SMS
                        Button(action: {
                            let cleaned = member.phoneNumber.replacingOccurrences(of: " ", with: "")
                            if let url = URL(string: "sms:\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "message.fill")
                                Text("Message")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(AppTheme.cyberCyan))
                            .shadow(color: AppTheme.cyberCyan.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 10)
                
                // Segmented control: Health Info vs Medications
                Picker("", selection: $selectedTab) {
                    Text("Health Telemetry").tag(0)
                    Text("Medications").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                if selectedTab == 0 {
                    // Health Info Rows
                    VStack(spacing: 14) {
                        ProfileVitalRow(
                            title: "Blood Pressure",
                            value: "118/76 mmHg",
                            status: "Optimal",
                            iconName: "gauge.with.needle.fill",
                            color: Color(red: 225/255, green: 29/255, blue: 72/255)
                        )
                        
                        ProfileVitalRow(
                            title: "Heart Rate",
                            value: "74 bpm",
                            status: "Normal",
                            iconName: "heart.fill",
                            color: Color(red: 239/255, green: 68/255, blue: 68/255)
                        )
                        
                        ProfileVitalRow(
                            title: "Blood Sugar",
                            value: "92 mg/dL",
                            status: "Normal",
                            iconName: "drop.fill",
                            color: Color(red: 14/255, green: 165/255, blue: 233/255)
                        )
                        
                        // Clinical Notes
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.18))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "note.text")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Clinical Notes")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                Text(member.notes.isEmpty ? "No special precautions registered" : member.notes)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .futuristicCard(cornerRadius: 18)
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Medications List for this member
                    let memberMeds = store.medicines.filter { $0.assignedMemberName == member.name || $0.assignedMemberName == "All" }
                    VStack(spacing: 12) {
                        if memberMeds.isEmpty {
                            Text("No specific medications assigned to this member.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(memberMeds) { med in
                                HStack {
                                    Image(systemName: med.form.iconName)
                                        .foregroundColor(AppTheme.primaryRed)
                                        .font(.title2)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(med.name)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                        Text(med.doseDescription)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(med.stockCount) left")
                                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                                        .foregroundColor(med.isLowStock ? .red : .secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill((med.isLowStock ? Color.red : Color.secondary).opacity(0.12)))
                                }
                                .padding(16)
                                .futuristicCard(cornerRadius: 18)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Edit Profile Button
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Edit Profile & Telemetry")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.heroRedGradient)
                                .shadow(color: AppTheme.primaryRed.opacity(0.35), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .navigationTitle("Family Member")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditFamilyMemberSheet(member: $member)
                .environmentObject(store)
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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(status)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.neonGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(AppTheme.neonGreen.opacity(0.14))
                )
        }
        .padding(16)
        .futuristicCard(cornerRadius: 18)
    }
}

struct EditFamilyMemberSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    @Binding var member: FamilyMember
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var condition: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Information").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Primary Condition", text: $condition)
                    TextField("Medical Notes", text: $notes)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = member.name
                phone = member.phoneNumber
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
                        member.phoneNumber = phone
                        member.primaryCondition = condition
                        member.notes = notes
                        store.updateFamilyMember(member)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryRed)
                }
            }
        }
    }
}
