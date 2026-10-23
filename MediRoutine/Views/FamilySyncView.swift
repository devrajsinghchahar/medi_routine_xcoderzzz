import SwiftUI

struct FamilySyncView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header + "+ Add Member" button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr("Family Members"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(store.tr("Connect. Care. Together."))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        store.showingAddMemberSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add Member")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(AppTheme.primaryRed)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Family Member Cards List
                VStack(spacing: 12) {
                    ForEach(store.familyMembers) { member in
                        NavigationLink(destination: FamilyMemberProfileView(member: member)) {
                            HStack(spacing: 14) {
                                // Avatar Circle
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: member.avatarColorHex).opacity(0.18))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: member.avatarSystemName)
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(hex: member.avatarColorHex))
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(member.displayNameWithRelation)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(member.subtitle)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text("\(member.medicationsCount) meds")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppTheme.successGreen)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule().fill(AppTheme.successGreen.opacity(0.12))
                                        )
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .modernCard(cornerRadius: 18)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Family Health Summary Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.successGreen.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.successGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Family Health Summary")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(store.tr("All good! No critical alerts."))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(store.isDarkMode ? Color(red: 20/255, green: 35/255, blue: 25/255) : Color(red: 240/255, green: 253/255, blue: 244/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(AppTheme.successGreen.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                
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

// Color Hex Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// Add Member Sheet
struct AddFamilyMemberSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var name: String = ""
    @State private var relation: String = "Mother"
    @State private var age: String = "45"
    @State private var condition: String = "General"
    
    let relations = ["Father", "Mother", "Spouse", "Child", "Brother", "Sister", "Grandparent"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Full Name", text: $name)
                    Picker("Relationship", selection: $relation) {
                        ForEach(relations, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Medical Conditions")) {
                    TextField("Primary Condition (e.g. BP, Diabetes)", text: $condition)
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
                            store.addFamilyMember(name: name, relation: relation, age: a, condition: condition)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
