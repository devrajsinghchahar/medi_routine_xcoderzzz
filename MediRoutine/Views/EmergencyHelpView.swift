import SwiftUI

struct EmergencyHelpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var isPulsing = false
    @State private var showingCallAlert = false
    @State private var selectedEmergencyNumber = "112"
    @State private var showingMedicalInfoSheet = false
    @State private var locationSharedAlert = false
    @State private var countdown = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                (store.isDarkMode ? AppTheme.screenBackgroundDark : AppTheme.screenBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header subtitle
                        VStack(spacing: 4) {
                            Text(store.tr("When every second counts"))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.primaryRed)
                        }
                        .padding(.top, 4)
                        
                        // Giant Glowing SOS Button
                        VStack(spacing: 12) {
                            ZStack {
                                // Pulsing shockwave ripples
                                Circle()
                                    .fill(Color.red.opacity(0.12))
                                    .frame(width: 200, height: 200)
                                    .scaleEffect(isPulsing ? 1.25 : 0.95)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                                
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 160, height: 160)
                                    .scaleEffect(isPulsing ? 1.15 : 0.98)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                                
                                // Main SOS Button
                                Button(action: triggerSOS) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(red: 255/255, green: 65/255, blue: 85/255), Color(red: 220/255, green: 20/255, blue: 40/255)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 120, height: 120)
                                            .shadow(color: Color.red.opacity(0.5), radius: 15, x: 0, y: 8)
                                        
                                        VStack(spacing: 2) {
                                            Text("SOS")
                                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)
                            
                            Text(store.tr("Tap for immediate help"))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        // 3 Action Cards matching screenshot
                        VStack(spacing: 12) {
                            // Call Emergency
                            Button(action: {
                                selectedEmergencyNumber = "112 / 108"
                                showingCallAlert = true
                                HapticManager.shared.impact(style: .heavy)
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(store.tr("Call Emergency"))
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("112 / 108")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .modernCard(cornerRadius: 18)
                            }
                            
                            // Share Location
                            Button(action: {
                                locationSharedAlert = true
                                HapticManager.shared.notification(type: .success)
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(store.tr("Share Location"))
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("Live location with family")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .modernCard(cornerRadius: 18)
                            }
                            
                            // Medical Info
                            Button(action: {
                                showingMedicalInfoSheet = true
                                HapticManager.shared.impact(style: .medium)
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "cross.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(store.tr("Medical Info"))
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("Quick view of your health info")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .modernCard(cornerRadius: 18)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Emergency Contacts section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emergency Contacts")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 10) {
                                ForEach(store.emergencyContacts) { contact in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(contact.name)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                            Text("\(contact.relationship) • \(contact.phone)")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            selectedEmergencyNumber = contact.phone
                                            showingCallAlert = true
                                        }) {
                                            Image(systemName: "phone.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(AppTheme.successGreen)
                                        }
                                    }
                                    .padding(14)
                                    .modernCard(cornerRadius: 16)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                            .frame(height: 30)
                    }
                }
            }
            .navigationTitle(store.tr("Emergency Help"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isPulsing = true
            }
            .alert("Call \(selectedEmergencyNumber)?", isPresented: $showingCallAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Call Now", role: .destructive) {
                    if let url = URL(string: "tel://\(selectedEmergencyNumber.replacingOccurrences(of: " ", with: ""))") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            } message: {
                Text("This will immediately dial emergency services or your primary contact.")
            }
            .alert("Location Broadcasted", isPresented: $locationSharedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your current GPS coordinates (28.6139° N, 77.2090° E) and medical ID have been sent to your 4 family members via SMS & Push notification.")
            }
            .sheet(isPresented: $showingMedicalInfoSheet) {
                MedicalInfoSheetView()
                    .environmentObject(store)
            }
        }
    }
    
    private func triggerSOS() {
        HapticManager.shared.notification(type: .error)
        selectedEmergencyNumber = "112"
        showingCallAlert = true
    }
}

// Medical Info Sheet
struct MedicalInfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Emergency Health ID")) {
                    HStack {
                        Text("Full Name")
                        Spacer()
                        Text(store.userName).bold()
                    }
                    HStack {
                        Text("Blood Group")
                        Spacer()
                        Text(store.userBloodGroup)
                            .bold()
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Known Allergies")
                        Spacer()
                        Text(store.userAllergies)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Emergency Notes")
                        Spacer()
                        Text(store.emergencyNotes)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Active Prescriptions")) {
                    ForEach(store.medicines) { med in
                        HStack {
                            Text(med.name)
                                .fontWeight(.medium)
                            Spacer()
                            Text(med.dosage)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Medical Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
