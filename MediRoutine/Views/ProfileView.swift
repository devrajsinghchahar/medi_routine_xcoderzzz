import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingEmergencyHelp = false
    @State private var showingEditProfile = false
    @State private var showingResetAlert = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header Avatar
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 84, height: 84)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(store.userName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        
                        Text(store.userEmail)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        Text("Blood: \(store.userBloodGroup)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primaryRed)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(AppTheme.primaryRed.opacity(0.12)))
                        
                        Text("Age 20 • General")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.secondary.opacity(0.12)))
                    }
                }
                .padding(.top, 10)
                
                // Settings Sections
                VStack(spacing: 14) {
                    // Appearance & Theme Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Preferences")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 12) {
                            // Dark Mode Toggle
                            HStack {
                                ZStack {
                                    Circle().fill(Color.purple.opacity(0.15)).frame(width: 36, height: 36)
                                    Image(systemName: "moon.fill").foregroundColor(.purple)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dark Mode")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("More comfortable for eyes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $store.isDarkMode)
                                    .labelsHidden()
                            }
                            
                            Divider()
                            
                            // Multi-Language Picker
                            HStack {
                                ZStack {
                                    Circle().fill(Color.blue.opacity(0.15)).frame(width: 36, height: 36)
                                    Image(systemName: "globe").foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Language / भाषा")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("English + Hindi")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Picker("", selection: $store.currentLanguage) {
                                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                                        Text(lang.rawValue).tag(lang)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                        .padding(16)
                        .modernCard(cornerRadius: 18)
                    }
                    .padding(.horizontal)
                    
                    // Quick Safety & Health section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Safety & Support")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                store.showingSOSSheet = true
                            }) {
                                HStack {
                                    ZStack {
                                        Circle().fill(Color.red.opacity(0.15)).frame(width: 36, height: 36)
                                        Image(systemName: "cross.fill").foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Emergency Help & SOS")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("112 / 108 direct access")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                ZStack {
                                    Circle().fill(Color.green.opacity(0.15)).frame(width: 36, height: 36)
                                    Image(systemName: "shield.checkmark.fill").foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Privacy & Medical Data")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("Stored locally on your Apple device")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(16)
                        .modernCard(cornerRadius: 18)
                    }
                    .padding(.horizontal)
                    
                    // App Information
                    VStack(spacing: 12) {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Text("Reset to Default Demo Data")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.primaryRed)
                        }
                        
                        Text("Medi Routine v2.0 • Healthy Today, Happier Tomorrow")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                store.loadMockData()
                HapticManager.shared.notification(type: .success)
            }
        } message: {
            Text("This will restore the original demo schedule, family members, and vitals from the design mockup.")
        }
    }
}
