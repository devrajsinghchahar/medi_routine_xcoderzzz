import SwiftUI

struct FamilySyncView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Header + "+ Add Member" button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(store.tr("Family Members"))
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Circle()
                                .fill(AppTheme.cyberCyan)
                                .frame(width: 8, height: 8)
                                .shadow(color: AppTheme.cyberCyan, radius: 4)
                        }
                        
                        Text(store.tr("Connect. Care. Together."))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        store.showingAddMemberSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 15, weight: .bold))
                            Text("Add Member")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            Capsule().fill(AppTheme.heroRedGradient)
                                .shadow(color: AppTheme.primaryRed.opacity(0.35), radius: 6, x: 0, y: 3)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Family Member Cards List
                VStack(spacing: 14) {
                    ForEach(store.familyMembers) { member in
                        NavigationLink(destination: FamilyMemberProfileView(member: member)) {
                            HStack(spacing: 16) {
                                // Avatar Circle
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: member.avatarColorHex).opacity(0.18))
                                        .frame(width: 52, height: 52)
                                    
                                    Image(systemName: member.avatarSystemName)
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(hex: member.avatarColorHex))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.displayNameWithRelation)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(member.subtitle)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Quick Call Button
                                if !member.phoneNumber.isEmpty {
                                    Button(action: {
                                        let cleaned = member.phoneNumber.replacingOccurrences(of: " ", with: "")
                                        if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Image(systemName: "phone.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(AppTheme.neonGreen)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                
                                HStack(spacing: 4) {
                                    Text("\(member.medicationsCount) meds")
                                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                                        .foregroundColor(AppTheme.neonGreen)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule().fill(AppTheme.neonGreen.opacity(0.14))
                                        )
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .futuristicCard(cornerRadius: 20)
                        }
                        .contextMenu {
                            Button(action: {
                                let cleaned = member.phoneNumber.replacingOccurrences(of: " ", with: "")
                                if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Label("Call \(member.name)", systemImage: "phone")
                            }
                            
                            Button(role: .destructive, action: {
                                store.deleteFamilyMember(id: member.id)
                            }) {
                                Label("Remove Member", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Family Health Summary Banner
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.neonGreen.opacity(0.18))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.neonGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Family Health Synchronized")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(store.tr("All good! No critical alerts."))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(store.isDarkMode ? Color(red: 20/255, green: 35/255, blue: 25/255) : Color(red: 240/255, green: 253/255, blue: 244/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(AppTheme.neonGreen.opacity(0.3), lineWidth: 1.2)
                        )
                )
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .sheet(isPresented: $store.showingAddMemberSheet) {
            AddFamilyMemberSheetView()
                .environmentObject(store)
        }
    }
}

// MARK: - Add Member Sheet
struct AddFamilyMemberSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var name: String = ""
    @State private var relation: String = "Mother"
    @State private var age: String = "45"
    @State private var phone: String = "+91 98765 43210"
    @State private var condition: String = "General Wellness"
    
    let relations = ["Father", "Mother", "Spouse", "Child", "Brother", "Sister", "Grandparent"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Details").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    TextField("Full Name", text: $name)
                    Picker("Relationship", selection: $relation) {
                        ForEach(relations, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Medical Conditions & Profile").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    TextField("Primary Condition (e.g. Hypertension)", text: $condition)
                }
            }
            .navigationTitle("Add Family Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !name.isEmpty, let a = Int(age) {
                            store.addFamilyMember(name: name, relation: relation, age: a, condition: condition, phone: phone)
                        }
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryRed)
                }
            }
        }
    }
}
