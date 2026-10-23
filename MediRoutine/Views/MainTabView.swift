import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Area
            Group {
                switch store.selectedTab {
                case 0:
                    NavigationView {
                        HomeDashboardView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    
                case 1:
                    NavigationView {
                        MedicineScheduleView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    
                case 2:
                    NavigationView {
                        HealthTrackerView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    
                case 3:
                    NavigationView {
                        FamilySyncView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    
                case 4:
                    NavigationView {
                        ReportsView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    
                case 5:
                    NavigationView {
                        ProfileView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    
                default:
                    HomeDashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Futuristic Biotech Dock Floating Tab Bar
            CustomFuturisticBottomBar(
                selectedTab: $store.selectedTab,
                onAddTap: {
                    store.showingAddMedicineSheet = true
                    HapticManager.shared.impact(style: .medium)
                }
            )
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $store.showingAddMedicineSheet) {
            AddMedicineView()
                .environmentObject(store)
        }
        .sheet(isPresented: $store.showingSOSSheet) {
            EmergencyHelpView()
                .environmentObject(store)
        }
        .sheet(isPresented: $store.showingPulseScanner) {
            BiometricPulseScannerView()
                .environmentObject(store)
        }
    }
}

// MARK: - Futuristic Floating Biotech Dock Bar
struct CustomFuturisticBottomBar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: DataStore
    @Binding var selectedTab: Int
    let onAddTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            FuturisticTabBarButton(
                title: "Home",
                icon: "house.fill",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            // Schedule
            FuturisticTabBarButton(
                title: "Schedule",
                icon: "calendar.badge.clock",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            // Center Elevated Holographic Add (+) Action Button
            Button(action: onAddTap) {
                ZStack {
                    // Pulsing Outer Glow Ring
                    Circle()
                        .stroke(AppTheme.primaryRed.opacity(0.3), lineWidth: 2)
                        .frame(width: 62, height: 62)
                    
                    Circle()
                        .fill(AppTheme.heroRedGradient)
                        .frame(width: 54, height: 54)
                        .shadow(color: AppTheme.primaryRed.opacity(0.55), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -14)
            .frame(maxWidth: .infinity)
            
            // Family
            FuturisticTabBarButton(
                title: "Family",
                icon: "person.2.fill",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            // Profile
            FuturisticTabBarButton(
                title: "Profile",
                icon: "person.crop.circle.fill",
                isSelected: selectedTab == 5
            ) {
                selectedTab = 5
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background(
            (store.isDarkMode ? Color(red: 16/255, green: 22/255, blue: 36/255) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.black.opacity(store.isDarkMode ? 0.45 : 0.08), radius: 18, x: 0, y: -2)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            store.isDarkMode
                                ? LinearGradient(colors: [Color.white.opacity(0.12), AppTheme.cyberCyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.black.opacity(0.06), Color.black.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.2
                        )
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

// MARK: - Tab Bar Button
struct FuturisticTabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? AppTheme.primaryRed : .secondary)
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.primaryRed : .secondary)
                
                // Micro glowing indicator dot under active tab
                if isSelected {
                    Circle()
                        .fill(AppTheme.primaryRed)
                        .frame(width: 4, height: 4)
                        .shadow(color: AppTheme.primaryRed, radius: 2)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
