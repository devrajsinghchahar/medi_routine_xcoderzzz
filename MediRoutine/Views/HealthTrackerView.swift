import SwiftUI

struct HealthTrackerView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedTab: String = "Vitals"
    @State private var showingAddVitalSheet: Bool = false
    @State private var selectedVitalTypeForChart: VitalType = .heartRate
    
    let tabs = ["Vitals", "Steps", "Sleep", "Weight"]
    
    // Dynamic history for the selected vital type
    var chartRecords: [VitalRecord] {
        let history = store.vitalsHistory(for: selectedVitalTypeForChart, limit: 7)
        if history.isEmpty {
            // Provide sensible fallback if no entries logged yet
            return [
                VitalRecord(type: selectedVitalTypeForChart, value: 72, date: Date()),
                VitalRecord(type: selectedVitalTypeForChart, value: 74, date: Date().addingTimeInterval(3600))
            ]
        }
        return history
    }
    
    var averageValueText: String {
        let values = chartRecords.map { $0.value }
        guard !values.isEmpty else { return "--" }
        let avg = values.reduce(0, +) / Double(values.count)
        if selectedVitalTypeForChart == .temperature {
            return String(format: "%.1f %@", avg, selectedVitalTypeForChart.unit)
        }
        return "\(Int(avg)) \(selectedVitalTypeForChart.unit)"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(store.tr("Health Tracker"))
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            // Futuristic live pulse indicator
                            Circle()
                                .fill(AppTheme.neonGreen)
                                .frame(width: 8, height: 8)
                                .shadow(color: AppTheme.neonGreen, radius: 4)
                        }
                        
                        Text("Live Biometric Telemetry & Trends")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Log Vital Button
                    Button(action: {
                        HapticManager.shared.impact(style: .medium)
                        showingAddVitalSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Log")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(AppTheme.heroRedGradient)
                                .shadow(color: AppTheme.primaryRed.opacity(0.35), radius: 6, x: 0, y: 3)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Futuristic Category Tabs: Vitals, Steps, Sleep, Weight
                HStack(spacing: 10) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                            HapticManager.shared.impact(style: .light)
                        }) {
                            Text(tab)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(selectedTab == tab ? AppTheme.primaryRed : (store.isDarkMode ? Color(red: 24/255, green: 32/255, blue: 50/255) : Color.white))
                                )
                                .foregroundColor(selectedTab == tab ? .white : .secondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(selectedTab == tab ? Color.clear : Color.secondary.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(selectedTab == tab ? 0.15 : 0.02), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                if selectedTab == "Vitals" {
                    // 2x2 Dynamic Grid of Vitals bound to DataStore
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        // Heart Rate
                        let hr = store.latestVital(for: .heartRate)
                        DynamicVitalCard(
                            type: .heartRate,
                            valueText: hr?.displayValue ?? "72",
                            unit: VitalType.heartRate.unit,
                            status: hr?.status ?? "Normal",
                            isSelected: selectedVitalTypeForChart == .heartRate
                        ) {
                            withAnimation(.spring()) { selectedVitalTypeForChart = .heartRate }
                        }
                        
                        // Blood Pressure
                        let bp = store.latestVital(for: .bloodPressure)
                        DynamicVitalCard(
                            type: .bloodPressure,
                            valueText: bp?.displayValue ?? "118/76",
                            unit: VitalType.bloodPressure.unit,
                            status: bp?.status ?? "Optimal",
                            isSelected: selectedVitalTypeForChart == .bloodPressure
                        ) {
                            withAnimation(.spring()) { selectedVitalTypeForChart = .bloodPressure }
                        }
                        
                        // Blood Sugar
                        let bs = store.latestVital(for: .bloodSugar)
                        DynamicVitalCard(
                            type: .bloodSugar,
                            valueText: bs?.displayValue ?? "92",
                            unit: VitalType.bloodSugar.unit,
                            status: bs?.status ?? "Normal",
                            isSelected: selectedVitalTypeForChart == .bloodSugar
                        ) {
                            withAnimation(.spring()) { selectedVitalTypeForChart = .bloodSugar }
                        }
                        
                        // Temperature
                        let temp = store.latestVital(for: .temperature)
                        DynamicVitalCard(
                            type: .temperature,
                            valueText: temp?.displayValue ?? "36.6",
                            unit: VitalType.temperature.unit,
                            status: temp?.status ?? "Normal",
                            isSelected: selectedVitalTypeForChart == .temperature
                        ) {
                            withAnimation(.spring()) { selectedVitalTypeForChart = .temperature }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                } else if selectedTab == "Steps" {
                    // Steps Card
                    let stepsRec = store.latestVital(for: .steps)
                    let currentSteps = Int(stepsRec?.value ?? 6840)
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DAILY STEP TARGET")
                                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                    .foregroundColor(Color.orange)
                                Text("\(currentSteps) / 10,000")
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            Image(systemName: "figure.walk")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                        }
                        
                        ProgressView(value: Double(currentSteps), total: 10000)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .scaleEffect(y: 2.5)
                        
                        HStack {
                            Text("Active Calories: ~\(Int(Double(currentSteps) * 0.04)) kcal")
                            Spacer()
                            Text("Goal: \(Int((Double(currentSteps) / 10000.0) * 100))%")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .futuristicCard(cornerRadius: 20)
                    .padding(.horizontal, 20)
                    
                } else if selectedTab == "Sleep" {
                    // Sleep Card
                    let sleepRec = store.latestVital(for: .sleep)
                    let sleepHours = sleepRec?.value ?? 7.5
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("CIRCADIAN REST CYCLE")
                                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                    .foregroundColor(AppTheme.quantumPurple)
                                Text(String(format: "%.1f hrs", sleepHours))
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.quantumPurple)
                        }
                        
                        HStack {
                            Text("Deep Sleep: 2.1 hrs")
                            Spacer()
                            Text("Sleep Quality: 91% (Restful)")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .futuristicCard(cornerRadius: 20)
                    .padding(.horizontal, 20)
                    
                } else {
                    // Weight Card
                    let weightRec = store.latestVital(for: .weight)
                    let weightKg = weightRec?.value ?? 68.0
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("BODY METRICS")
                                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                    .foregroundColor(AppTheme.cyberCyan)
                                Text(String(format: "%.1f kg", weightKg))
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            Image(systemName: "scalemass.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.cyberCyan)
                        }
                        
                        HStack {
                            Text("BMI: 21.8 (Healthy Weight)")
                            Spacer()
                            Text("Target: 66.0 kg")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .futuristicCard(cornerRadius: 20)
                    .padding(.horizontal, 20)
                }
                
                // MARK: - Dynamic Telemetry Trend Spline Chart
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(selectedVitalTypeForChart.rawValue) Telemetry")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Average: \(averageValueText)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(selectedVitalTypeForChart.color)
                        }
                        
                        Spacer()
                        
                        if selectedVitalTypeForChart == .heartRate {
                            Button(action: {
                                store.showingPulseScanner = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "waveform.path.ecg")
                                    Text("Scan Pulse")
                                }
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(AppTheme.heroRedGradient))
                            }
                        }
                    }
                    
                    // Spline Line Chart Canvas
                    DynamicSplineChart(records: chartRecords, vitalType: selectedVitalTypeForChart)
                        .frame(height: 140)
                        .padding(.top, 4)
                }
                .padding(20)
                .futuristicCard(cornerRadius: 22, glowColor: selectedVitalTypeForChart.color.opacity(0.15), glowRadius: 8)
                .padding(.horizontal, 20)
                
                // Bottom spacing for tab bar
                Spacer()
                    .frame(height: 100)
            }
        }
        .sheet(isPresented: $showingAddVitalSheet) {
            AddVitalSheetView()
                .environmentObject(store)
        }
        .sheet(isPresented: $store.showingPulseScanner) {
            BiometricPulseScannerView()
                .environmentObject(store)
        }
    }
}

// MARK: - Dynamic Vital Card Component
struct DynamicVitalCard: View {
    @Environment(\.colorScheme) var colorScheme
    let type: VitalType
    let valueText: String
    let unit: String
    let status: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(colorScheme == .dark ? 0.25 : 0.14))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: type.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(type.color)
                    }
                    
                    Spacer()
                    
                    Text(status)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.neonGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(AppTheme.neonGreen.opacity(0.14))
                        )
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(type.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(valueText)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(unit)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .futuristicCard(
                cornerRadius: 20,
                glowColor: isSelected ? type.color : Color.clear,
                glowRadius: isSelected ? 8 : 0
            )
        }
    }
}

// MARK: - Dynamic Spline Chart Canvas
struct DynamicSplineChart: View {
    let records: [VitalRecord]
    let vitalType: VitalType
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = max(records.count, 2)
            let stepX = w / CGFloat(count - 1)
            
            let values = records.map { CGFloat($0.value) }
            let minVal = (values.min() ?? 60) - 5
            let maxVal = (values.max() ?? 100) + 5
            let range = max(maxVal - minVal, 1)
            
            ZStack {
                // Background grid lines
                VStack {
                    Divider().opacity(0.3)
                    Spacer()
                    Divider().opacity(0.3)
                    Spacer()
                    Divider().opacity(0.3)
                }
                
                // Area gradient below path
                Path { path in
                    for (i, val) in values.enumerated() {
                        let normalizedY = h - ((val - minVal) / range * h)
                        let x = CGFloat(i) * stepX
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: normalizedY))
                        } else {
                            let prevX = CGFloat(i - 1) * stepX
                            let prevVal = values[i - 1]
                            let prevY = h - ((prevVal - minVal) / range * h)
                            let midX = (prevX + x) / 2
                            path.addCurve(to: CGPoint(x: x, y: normalizedY), control1: CGPoint(x: midX, y: prevY), control2: CGPoint(x: midX, y: normalizedY))
                        }
                    }
                    path.addLine(to: CGPoint(x: CGFloat(count - 1) * stepX, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [vitalType.color.opacity(0.3), vitalType.color.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Curve Stroke
                Path { path in
                    for (i, val) in values.enumerated() {
                        let normalizedY = h - ((val - minVal) / range * h)
                        let x = CGFloat(i) * stepX
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: normalizedY))
                        } else {
                            let prevX = CGFloat(i - 1) * stepX
                            let prevVal = values[i - 1]
                            let prevY = h - ((prevVal - minVal) / range * h)
                            let midX = (prevX + x) / 2
                            path.addCurve(to: CGPoint(x: x, y: normalizedY), control1: CGPoint(x: midX, y: prevY), control2: CGPoint(x: midX, y: normalizedY))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [vitalType.color, vitalType.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round)
                )
                
                // Data points
                ForEach(0..<values.count, id: \.self) { i in
                    let val = values[i]
                    let normalizedY = h - ((val - minVal) / range * h)
                    let x = CGFloat(i) * stepX
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(vitalType.color, lineWidth: 2.5))
                        .shadow(color: vitalType.color.opacity(0.5), radius: 3)
                        .position(x: x, y: normalizedY)
                }
            }
        }
    }
}

// MARK: - Add Vital Sheet
struct AddVitalSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: DataStore
    
    @State private var selectedType: VitalType = .heartRate
    @State private var valueString: String = "72"
    @State private var secondaryValueString: String = "76"
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Biometric Category").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(VitalType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Value (\(selectedType.unit))").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    TextField("Value", text: $valueString)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    if selectedType == .bloodPressure {
                        TextField("Diastolic (e.g. 76)", text: $secondaryValueString)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                }
                
                Section(header: Text("Clinical Notes / Context").font(.system(size: 12, weight: .bold, design: .monospaced))) {
                    TextField("e.g. Resting after morning walk", text: $notes)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
            }
            .navigationTitle("Log Vital")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let val = Double(valueString) {
                            let sec = Double(secondaryValueString)
                            store.addVital(type: selectedType, value: val, secondary: sec, notes: notes)
                        }
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryRed)
                }
            }
        }
    }
}
