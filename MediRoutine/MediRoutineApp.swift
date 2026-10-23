import SwiftUI

@main
struct MediRoutineApp: App {
    @StateObject private var store = DataStore()
    @State private var isSplashFinished = ProcessInfo.processInfo.arguments.contains("-noSplash")
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !isSplashFinished {
                    SplashScreenView(isFinished: $isSplashFinished)
                } else {
                    MainTabView()
                        .environmentObject(store)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .preferredColorScheme(store.isDarkMode ? .dark : .light)
        }
    }
}
