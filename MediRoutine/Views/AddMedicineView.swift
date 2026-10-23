import SwiftUI

struct AddMedicineView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var medicineName: String = ""
    @State private var dosage: String = "500 mg"
    @State private var quantity: Int = 1
    @State private var selectedForm: MedicineForm = .tablet
    @State private var selectedTiming: MealTiming = .afterFood
    @State private var selectedTime: Date = Date()
    @State private var repeatInterval: String = "Daily"
    @State private var selectedMemberName: String = "Ayush"
    
    let popularMedicines = [
        "Paracetamol", "Vitamin D3", "Atorvastatin", "Metformin", "Amoxicillin", "Cetirizine", "Omeprazole", "Ibuprofen"
    ]
    
    let repeatOptions = ["Daily", "Alternate Days", "Weekly", "Specific Days"]
    let dosageOptions = ["250 mg", "500 mg", "650 mg", "1000 IU", "5 mg", "10 mg", "20 mg", "50 mg", "5 ml"]
    
    var body: some View {
        NavigationView {
            ZStack {
                (store.isDarkMode ? AppTheme.screenBackgroundDark : AppTheme.screenBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header pill
                        HStack(spacing: 8) {
                            Image(systemName: "pills.circle.fill")
                                .foregroundColor(AppTheme.primaryRed)
                                .font(.title3)
                            Text("Quick & Easy Medicine Setup")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Medicine Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medicine Name")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("e.g. Paracetamol", text: $medicineName)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            
                            // Popular Pills ScrollView
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(popularMedicines, id: \.self) { med in
                                        Button(action: {
                                            medicineName = med
                                            HapticManager.shared.impact(style: .light)
                                        }) {
                                            Text(med)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule()
                                                        .fill(medicineName == med ? AppTheme.primaryRed.opacity(0.15) : (store.isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.05)))
                                                )
                                                .foregroundColor(medicineName == med ? AppTheme.primaryRed : .primary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Dosage & Form
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dosage & Quantity")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Menu {
                                    ForEach(dosageOptions, id: \.self) { option in
                                        Button(option) {
                                            dosage = option
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(dosage)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                    )
                                }
                                
                                Stepper("\(quantity) \(selectedForm.rawValue)", value: $quantity, in: 1...10)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                    )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Medicine Form Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type of Medicine")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 10) {
                                ForEach(MedicineForm.allCases, id: \.self) { form in
                                    Button(action: {
                                        selectedForm = form
                                        HapticManager.shared.impact(style: .light)
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: form.iconName)
                                                .font(.system(size: 20))
                                            Text(form.rawValue.capitalized)
                                                .font(.system(size: 11, weight: .medium))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedForm == form ? AppTheme.primaryRed : (store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white))
                                        )
                                        .foregroundColor(selectedForm == form ? .white : .primary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedForm == form ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Frequency / Food timing
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(MealTiming.allCases, id: \.self) { timing in
                                    Button(timing.rawValue) {
                                        selectedTiming = timing
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedTiming.rawValue)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Reminder Time Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminder Time")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Image(systemName: "clock.fill")
                                    .foregroundColor(AppTheme.primaryRed)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                            )
                        }
                        .padding(.horizontal)
                        
                        // Repeat Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeat")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(repeatOptions, id: \.self) { option in
                                    Button(option) {
                                        repeatInterval = option
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(repeatInterval)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Assign to Family Member
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assign to Family Member")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(store.familyMembers) { member in
                                        Button(action: {
                                            selectedMemberName = member.name
                                            HapticManager.shared.impact(style: .light)
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "person.crop.circle.fill")
                                                Text(member.name)
                                            }
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedMemberName == member.name ? AppTheme.primaryRed : (store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white))
                                            )
                                            .foregroundColor(selectedMemberName == member.name ? .white : .primary)
                                            .overlay(
                                                Capsule().stroke(selectedMemberName == member.name ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Save Reminder Button
                        Button(action: saveMedicine) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                Text("Save Reminder")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.heroRedGradient)
                                    .shadow(color: AppTheme.primaryRed.opacity(0.4), radius: 10, x: 0, y: 5)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                        .disabled(medicineName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(medicineName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Add Medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveMedicine() {
        guard !medicineName.isEmpty else { return }
        store.addMedicine(
            name: medicineName,
            dosage: dosage,
            form: selectedForm,
            quantity: quantity,
            timing: selectedTiming,
            time: selectedTime,
            memberName: selectedMemberName
        )
        dismiss()
    }
}
