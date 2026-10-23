import SwiftUI
import UIKit

struct ReportsView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedPeriod = 0 // 0: Weekly, 1: Monthly, 2: Yearly
    @State private var showingShareActivity = false
    @State private var animatedAdherence: Double = 0.0
    
    let periods = ["Weekly", "Monthly", "Yearly"]
    
    var currentAdherence: Double {
        store.overallAdherencePercentage()
    }
    
    var dosesSummary: (taken: Int, total: Int) {
        store.totalDosesSummary()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(store.tr("Health Reports"))
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Circle()
                                .fill(AppTheme.quantumPurple)
                                .frame(width: 8, height: 8)
                                .shadow(color: AppTheme.quantumPurple, radius: 4)
                        }
                        
                        Text(store.tr("See your progress"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Real iOS Share Sheet Button
                    Button(action: {
                        HapticManager.shared.impact(style: .medium)
                        showingShareActivity = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Export")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(AppTheme.quantumPurpleGradient)
                                .shadow(color: AppTheme.quantumPurple.opacity(0.4), radius: 6, x: 0, y: 3)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Segmented Range Control
                Picker("", selection: $selectedPeriod) {
                    ForEach(0..<periods.count, id: \.self) { index in
                        Text(periods[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                // Medicine Adherence Dynamic Telemetry Card
                VStack(spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MEDICATION ADHERENCE TELEMETRY")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                .foregroundColor(AppTheme.cyberCyan)
                            
                            Text(store.tr("Medicine Adherence"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    }
                    
                    HStack(spacing: 24) {
                        // Dynamic Circular Progress Ring
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.12), lineWidth: 14)
                                .frame(width: 124, height: 124)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(animatedAdherence / 100.0, 1.0)))
                                .stroke(
                                    LinearGradient(
                                        colors: [AppTheme.neonGreen, AppTheme.cyberCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 124, height: 124)
                                .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 8, x: 0, y: 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animatedAdherence)
                            
                            VStack(spacing: 0) {
                                Text("\(Int(currentAdherence))%")
                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("COMPLIANCE")
                                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .heavy))
                                Text("+5.2%")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.neonGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(AppTheme.neonGreen.opacity(0.14))
                            )
                            
                            Text("from last cycle")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("\(dosesSummary.taken) of \(dosesSummary.total) scheduled doses")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .padding(20)
                .futuristicCard(cornerRadius: 22, glowColor: AppTheme.neonGreen.opacity(0.18), glowRadius: 8)
                .padding(.horizontal, 20)
                .onAppear {
                    animatedAdherence = currentAdherence
                }
                .onChange(of: currentAdherence) { _, newVal in
                    animatedAdherence = newVal
                }
                
                // Medicine Taken Dynamic Bar Chart
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.tr("Medicine Taken"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("7-Day Breakdown")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Goal: 100%")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.neonGreen)
                    }
                    
                    HStack(alignment: .bottom, spacing: 14) {
                        ForEach(store.adherenceStats) { stat in
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottom) {
                                    // Background track
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.secondary.opacity(0.12))
                                        .frame(width: 24, height: 110)
                                    
                                    // Progress bar
                                    let percentage = stat.adherencePercentage
                                    let fillHeight = (CGFloat(percentage) / 100.0) * 110
                                    
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    percentage >= 80 ? AppTheme.neonGreen : (percentage >= 50 ? AppTheme.cyberCyan : AppTheme.alertOrange),
                                                    percentage >= 80 ? Color(red: 20/255, green: 220/255, blue: 130/255) : Color(red: 0/255, green: 170/255, blue: 255/255)
                                                ],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 24, height: max(fillHeight, 8))
                                        .shadow(color: (percentage >= 80 ? AppTheme.neonGreen : AppTheme.cyberCyan).opacity(0.35), radius: 4, x: 0, y: -2)
                                }
                                
                                Text(stat.dayShort)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 145)
                    .padding(.top, 4)
                }
                .padding(20)
                .futuristicCard(cornerRadius: 22)
                .padding(.horizontal, 20)
                
                // Real-Life Health Insights & Doctor Sharing
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.neonGreen.opacity(0.18))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.neonGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.tr("Health Insights"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(store.tr("Great job! You are consistent with your medicines."))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Share with Doctor CTA Button
                    Button(action: {
                        HapticManager.shared.notification(type: .success)
                        showingShareActivity = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text.badge.plus")
                                .font(.system(size: 16, weight: .bold))
                            Text("Export Clinical Summary for Doctor")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(AppTheme.primaryRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.primaryRed.opacity(0.1))
                        )
                    }
                }
                .padding(18)
                .futuristicCard(cornerRadius: 20, glowColor: AppTheme.neonGreen.opacity(0.15), glowRadius: 6)
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .sheet(isPresented: $showingShareActivity) {
            RealLifeActivityView(activityItems: [store.generateMedicalReportText()])
        }
    }
}

// MARK: - Native iOS Activity Share Controller
struct RealLifeActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<RealLifeActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<RealLifeActivityView>) {}
}
