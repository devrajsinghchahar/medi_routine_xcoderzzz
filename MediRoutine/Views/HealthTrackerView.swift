import SwiftUI

struct HealthTrackerView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedTab: String = "Vitals"
    @State private var showingAddVitalSheet: Bool = false
    
    let tabs = ["Vitals", "Steps", "Sleep", "Weight"]
    
    // Weekly chart points
    let weeklyValues: [CGFloat] = [70, 72, 68, 74, 71, 73, 72]
    let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr("Health Tracker"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Track your wellness")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Log Vital button
                    Button(action: {
                        showingAddVitalSheet = true
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                            Text("Log")
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
                
                // Tabs: Vitals, Steps, Sleep, Weight
                HStack(spacing: 10) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                            HapticManager.shared.impact(style: .light)
                        }) {
                            Text(tab)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTab == tab ? AppTheme.primaryRed : (store.isDarkMode ? AppTheme.cardBackgroundDark : Color.white))
                                )
                                .foregroundColor(selectedTab == tab ? .white : .secondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedTab == tab ? Color.clear : Color.secondary.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(selectedTab == tab ? 0.08 : 0.02), radius: 3, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal)
                
                if selectedTab == "Vitals" {
                    // 2x2 Grid of Vitals
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        // Heart Rate
                        VitalCard(
                            title: "Heart Rate",
                            value: "72",
                            unit: "bpm",
                            status: "Normal",
                            iconName: "heart.fill",
                            accentColor: Color(red: 239/255, green: 68/255, blue: 68/255),
                            bgCircleColor: Color(red: 254/255, green: 242/255, blue: 242/255)
                        )
                        
                        // Blood Pressure
                        VitalCard(
                            title: "Blood Pressure",
                            value: "118/76",
                            unit: "mmHg",
                            status: "Normal",
                            iconName: "gauge.with.needle.fill",
                            accentColor: Color(red: 225/255, green: 29/255, blue: 72/255),
                            bgCircleColor: Color(red: 255/255, green: 241/255, blue: 242/255)
                        )
                        
                        // Blood Sugar
                        VitalCard(
                            title: "Blood Sugar",
                            value: "92",
                            unit: "mg/dL",
                            status: "Normal",
                            iconName: "drop.fill",
                            accentColor: Color(red: 14/255, green: 165/255, blue: 233/255),
                            bgCircleColor: Color(red: 240/255, green: 249/255, blue: 255/255)
                        )
                        
                        // Temperature
                        VitalCard(
                            title: "Temperature",
                            value: "36.6",
                            unit: "°C",
                            status: "Normal",
                            iconName: "thermometer.medium",
                            accentColor: Color(red: 34/255, green: 197/255, blue: 94/255),
                            bgCircleColor: Color(red: 240/255, green: 253/255, blue: 244/255)
                        )
                    }
                    .padding(.horizontal)
                } else if selectedTab == "Steps" {
                    // Steps Card
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Step Goal")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("6,840 / 10,000")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Image(systemName: "figure.walk")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)
                        }
                        
                        ProgressView(value: 6840, total: 10000)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .scaleEffect(y: 2)
                    }
                    .padding(18)
                    .modernCard(cornerRadius: 18)
                    .padding(.horizontal)
                } else if selectedTab == "Sleep" {
                    // Sleep Card
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Night's Sleep")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("7 hrs 30 mins")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.purple)
                        }
                        HStack {
                            Text("Deep Sleep: 2.1 hrs")
                            Spacer()
                            Text("Quality: 88%")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(18)
                    .modernCard(cornerRadius: 18)
                    .padding(.horizontal)
                } else {
                    // Weight Card
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Weight")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("68.0 kg")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Image(systemName: "scalemass.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.cyan)
                        }
                        HStack {
                            Text("BMI: 21.8 (Healthy)")
                            Spacer()
                            Text("Goal: 66 kg")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(18)
                    .modernCard(cornerRadius: 18)
                    .padding(.horizontal)
                }
                
                // Weekly Overview Section
                VStack(spacing: 14) {
                    HStack {
                        Text("Weekly Overview")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("View Details >")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.primaryRed)
                    }
                    .padding(.horizontal)
                    
                    // Smooth Line Chart
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Heart Rate Trend (BPM)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Avg: 71 bpm")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.successGreen)
                        }
                        
                        GeometryReader { geo in
                            let width = geo.size.width
                            let height = geo.size.height
                            let stepX = width / CGFloat(weeklyValues.count - 1)
                            
                            // Background grid lines
                            VStack {
                                Divider()
                                Spacer()
                                Divider()
                                Spacer()
                                Divider()
                            }
                            
                            // Spline curve
                            Path { path in
                                for (index, val) in weeklyValues.enumerated() {
                                    // Scale val between 65 and 75 to height
                                    let normalizedY = height - ((val - 65) / 10.0 * height)
                                    let x = CGFloat(index) * stepX
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: normalizedY))
                                    } else {
                                        let prevX = CGFloat(index - 1) * stepX
                                        let prevVal = weeklyValues[index - 1]
                                        let prevY = height - ((prevVal - 65) / 10.0 * height)
                                        let midX = (prevX + x) / 2
                                        path.addCurve(to: CGPoint(x: x, y: normalizedY), control1: CGPoint(x: midX, y: prevY), control2: CGPoint(x: midX, y: normalizedY))
                                    }
                                }
                            }
                            .stroke(
                                LinearGradient(colors: [AppTheme.successGreen, Color(red: 16/255, green: 185/255, blue: 129/255)], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                            
                            // Data Point circles
                            ForEach(0..<weeklyValues.count, id: \.self) { index in
                                let val = weeklyValues[index]
                                let normalizedY = height - ((val - 65) / 10.0 * height)
                                let x = CGFloat(index) * stepX
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                    .overlay(Circle().stroke(AppTheme.successGreen, lineWidth: 2))
                                    .position(x: x, y: normalizedY)
                            }
                        }
                        .frame(height: 120)
                        
                        // Days X-axis
                        HStack {
                            ForEach(weekDays, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .modernCard(cornerRadius: 18)
                    .padding(.horizontal)
                }
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .sheet(isPresented: $showingAddVitalSheet) {
            AddVitalSheetView()
                .environmentObject(store)
        }
    }
}

// MARK: - Vital Card Component
struct VitalCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    let unit: String
    let status: String
    let iconName: String
    let accentColor: Color
    let bgCircleColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? accentColor.opacity(0.2) : bgCircleColor)
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                }
                
                Spacer()
                
                Text(status)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.successGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(AppTheme.successGreen.opacity(0.12))
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .modernCard(cornerRadius: 18)
    }
}

// MARK: - Add Vital Sheet
struct AddVitalSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var selectedType: VitalType = .heartRate
    @State private var valueString: String = "72"
    @State private var secondaryValueString: String = "76"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vital Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(VitalType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Reading Value (\(selectedType.unit))")) {
                    TextField("Enter value", text: $valueString)
                        .keyboardType(.decimalPad)
                    
                    if selectedType == .bloodPressure {
                        TextField("Diastolic (e.g. 76)", text: $secondaryValueString)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Log Vital")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let val = Double(valueString) {
                            let sec = Double(secondaryValueString)
                            store.addVital(type: selectedType, value: val, secondary: sec)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
