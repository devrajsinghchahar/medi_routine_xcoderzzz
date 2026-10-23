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
            
            // Custom Curved Modern Floating Tab Bar
            CustomBottomBar(
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
    }
}

// MARK: - Custom Bottom Bar
struct CustomBottomBar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: DataStore
    @Binding var selectedTab: Int
    let onAddTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(
                title: "Home",
                icon: "house.fill",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            // Schedule
            TabBarButton(
                title: "Schedule",
                icon: "calendar",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            // Center Elevated Add (+) Button
            Button(action: onAddTap) {
                ZStack {
                    Circle()
                        .fill(AppTheme.heroRedGradient)
                        .frame(width: 54, height: 54)
                        .shadow(color: AppTheme.primaryRed.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -14)
            .frame(maxWidth: .infinity)
            
            // Family
            TabBarButton(
                title: "Family",
                icon: "person.2.fill",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            // Profile
            TabBarButton(
                title: "Profile",
                icon: "person.fill",
                isSelected: selectedTab == 5
            ) {
                selectedTab = 5
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background(
            (store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.black.opacity(store.isDarkMode ? 0.35 : 0.08), radius: 15, x: 0, y: -2)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(store.isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.03), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? AppTheme.primaryRed : .secondary)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.primaryRed : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
