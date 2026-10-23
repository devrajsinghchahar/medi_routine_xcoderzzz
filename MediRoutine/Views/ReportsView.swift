import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedPeriod = 0 // 0: Weekly, 1: Monthly, 2: Yearly
    @State private var showingShareSheet = false
    
    let periods = ["Weekly", "Monthly", "Yearly"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr("Health Reports"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(store.tr("See your progress"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.primaryRed)
                            .padding(10)
                            .background(
                                Circle().fill(AppTheme.primaryRed.opacity(0.12))
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Segmented Range Control
                Picker("", selection: $selectedPeriod) {
                    ForEach(0..<periods.count, id: \.self) { index in
                        Text(periods[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Medicine Adherence Card
                VStack(spacing: 16) {
                    HStack {
                        Text(store.tr("Medicine Adherence"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(spacing: 24) {
                        // Circular Progress Ring (92%)
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 12)
                                .frame(width: 110, height: 110)
                            
                            Circle()
                                .trim(from: 0.0, to: 0.92)
                                .stroke(
                                    LinearGradient(colors: [Color(red: 20/255, green: 184/255, blue: 166/255), Color(red: 16/255, green: 185/255, blue: 129/255)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 110, height: 110)
                            
                            VStack(spacing: 0) {
                                Text("92%")
                                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .bold))
                                Text("5%")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.successGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(AppTheme.successGreen.opacity(0.12))
                            )
                            
                            Text("from last week")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("19 of 21 doses taken")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .padding(18)
                .modernCard(cornerRadius: 20)
                .padding(.horizontal)
                
                // Medicine Taken Bar Chart
                VStack(alignment: .leading, spacing: 14) {
                    Text(store.tr("Medicine Taken"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(alignment: .bottom, spacing: 14) {
                        ForEach(store.adherenceStats) { stat in
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottom) {
                                    // Background track
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.secondary.opacity(0.12))
                                        .frame(width: 22, height: 100)
                                    
                                    // Progress bar
                                    let fillHeight = (CGFloat(stat.takenCount) / CGFloat(stat.totalCount)) * 100
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(red: 16/255, green: 185/255, blue: 129/255), Color(red: 52/255, green: 211/255, blue: 153/255)],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 22, height: fillHeight)
                                }
                                
                                Text(stat.dayShort)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 130)
                    .padding(.top, 6)
                }
                .padding(18)
                .modernCard(cornerRadius: 20)
                .padding(.horizontal)
                
                // Health Insights Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.successGreen.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.successGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr("Health Insights"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(store.tr("Great job! You are consistent with your medicines."))
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
        .sheet(isPresented: $showingShareSheet) {
            ShareReportSheetView()
        }
    }
}

// Share Report Sheet
struct ShareReportSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryRed)
                    .padding(.top, 40)
                
                Text("Weekly Health & Adherence Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Export formatted PDF summary ready to share with your family doctor.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share with Doctor")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.heroRedGradient))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
