import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Codable {
    case english = "English"
    case hindi = "हिंदी (Hindi)"
}

class DataStore: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isDarkMode: Bool = false {
        didSet { savePreferences() }
    }
    @Published var currentLanguage: AppLanguage = .english {
        didSet { savePreferences() }
    }
    
    // User Profile
    @Published var userName: String = "Ayush" {
        didSet { savePreferences() }
    }
    @Published var userEmail: String = "ayush@mediroutine.com" {
        didSet { savePreferences() }
    }
    @Published var userBloodGroup: String = "O+" {
        didSet { savePreferences() }
    }
    @Published var userAllergies: String = "Peanuts, Dust" {
        didSet { savePreferences() }
    }
    @Published var emergencyNotes: String = "Carry inhaler during winter" {
        didSet { savePreferences() }
    }
    
    // Core Data collections
    @Published var medicines: [Medicine] = [] {
        didSet { saveMedicines() }
    }
    @Published var todaySchedule: [ScheduledDose] = [] {
        didSet { saveSchedule() }
    }
    @Published var familyMembers: [FamilyMember] = [] {
        didSet { saveFamily() }
    }
    @Published var vitals: [VitalRecord] = [] {
        didSet { saveVitals() }
    }
    @Published var emergencyContacts: [EmergencyContact] = [] {
        didSet { saveContacts() }
    }
    @Published var adherenceStats: [DayDoseStat] = [] {
        didSet { saveStats() }
    }
    
    // UI Navigation & Interactive Sheets
    @Published var unreadNotificationsCount: Int = 2
    @Published var showingAddMedicineSheet: Bool = false
    @Published var showingSOSSheet: Bool = false
    @Published var showingLogVitalSheet: Bool = false
    @Published var showingAddMemberSheet: Bool = false
    @Published var showingPulseScanner: Bool = false
    @Published var scheduleSearchText: String = ""
    @Published var scheduleFilterStatus: Int = 0 // 0: All, 1: Pending, 2: Taken
    
    private let defaults = UserDefaults.standard
    
    init() {
        loadData()
        
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-dark") {
            isDarkMode = true
        }
        if args.contains("-sos") {
            showingSOSSheet = true
        }
        if args.contains("-addMed") {
            showingAddMedicineSheet = true
        }
        if let tabIdx = args.firstIndex(of: "-tab"), tabIdx + 1 < args.count, let t = Int(args[tabIdx + 1]) {
            selectedTab = t
        }
    }
    
    // MARK: - Localized String Helper
    func tr(_ key: String) -> String {
        guard currentLanguage == .hindi else { return key }
        
        switch key {
        case "Good Morning": return "शुभ प्रभात"
        case "Good Afternoon": return "शुभ दोपहर"
        case "Good Evening": return "शुभ संध्या"
        case "Stay healthy, stay happy!": return "स्वस्थ रहें, खुश रहें!"
        case "Next Medicine": return "अगली दवा"
        case "Take Now": return "अभी लें"
        case "Health Tracker": return "स्वास्थ्य ट्रैकर"
        case "Family Sync": return "पारिवारिक सिंक"
        case "Reports": return "रिपोर्ट्स"
        case "Emergency": return "आपातकालीन"
        case "Today's Schedule": return "आज का शेड्यूल"
        case "View All": return "सभी देखें"
        case "Medicine Schedule": return "दवा का शेड्यूल"
        case "Never miss a dose": return "कभी कोई खुराक न भूलें"
        case "Add Medicine": return "दवा जोड़ें"
        case "+ Add Medicine": return "+ दवा जोड़ें"
        case "Set custom reminder for any medicine.": return "किसी भी दवा के लिए कस्टम रिमाइंडर सेट करें।"
        case "Family Members": return "परिवार के सदस्य"
        case "Connect. Care. Together.": return "जुड़ें। देखभाल करें। साथ।"
        case "All good! No critical alerts.": return "सब ठीक है! कोई गंभीर सूचना नहीं।"
        case "Health Reports": return "स्वास्थ्य रिपोर्ट"
        case "See your progress": return "अपनी प्रगति देखें"
        case "Medicine Adherence": return "दवा अनुपालन"
        case "Medicine Taken": return "ली गई दवाएं"
        case "Health Insights": return "स्वास्थ्य अंतर्दृष्टि"
        case "Great job! You are consistent with your medicines.": return "शानदार काम! आप अपनी दवाओं के प्रति नियमित हैं।"
        case "Emergency Help": return "आपातकालीन सहायता"
        case "When every second counts": return "जब हर सेकंड मायने रखता है"
        case "Tap for immediate help": return "तत्काल सहायता के लिए टैप करें"
        case "Call Emergency": return "आपातकालीन कॉल करें"
        case "Share Location": return "स्थान साझा करें"
        case "Medical Info": return "चिकित्सा जानकारी"
        default: return key
        }
    }
    
    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return tr("Good Morning")
        } else if hour < 17 {
            return tr("Good Afternoon")
        } else {
            return tr("Good Evening")
        }
    }
    
    func nextMedicine() -> ScheduledDose? {
        return todaySchedule.first(where: { !$0.isTaken }) ?? todaySchedule.first
    }
    
    // MARK: - Medication Actions
    func toggleDoseTaken(doseId: UUID) {
        if let index = todaySchedule.firstIndex(where: { $0.id == doseId }) {
            let wasTaken = todaySchedule[index].isTaken
            todaySchedule[index].isTaken.toggle()
            todaySchedule[index].takenAt = todaySchedule[index].isTaken ? Date() : nil
            
            // Adjust stock of related medicine in real time
            let medId = todaySchedule[index].medicineId
            if let medIdx = medicines.firstIndex(where: { $0.id == medId }) {
                if !wasTaken {
                    // Marked taken: consume stock
                    medicines[medIdx].stockCount = max(0, medicines[medIdx].stockCount - todaySchedule[index].quantityPerDose(fallback: 1))
                } else {
                    // Unmarked: restore stock
                    medicines[medIdx].stockCount += todaySchedule[index].quantityPerDose(fallback: 1)
                }
            }
            
            HapticManager.shared.notification(type: .success)
            updateAdherence()
        }
    }
    
    func markAllDosesTaken() {
        for index in todaySchedule.indices {
            if !todaySchedule[index].isTaken {
                todaySchedule[index].isTaken = true
                todaySchedule[index].takenAt = Date()
                let medId = todaySchedule[index].medicineId
                if let medIdx = medicines.firstIndex(where: { $0.id == medId }) {
                    medicines[medIdx].stockCount = max(0, medicines[medIdx].stockCount - 1)
                }
            }
        }
        HapticManager.shared.notification(type: .success)
        updateAdherence()
    }
    
    func refillMedicine(medicineId: UUID, amount: Int = 30) {
        if let index = medicines.firstIndex(where: { $0.id == medicineId }) {
            medicines[index].stockCount += amount
            HapticManager.shared.notification(type: .success)
        }
    }
    
    func deleteMedicine(id: UUID) {
        medicines.removeAll(where: { $0.id == id })
        todaySchedule.removeAll(where: { $0.medicineId == id })
        HapticManager.shared.impact(style: .medium)
        updateAdherence()
    }
    
    func addMedicine(name: String, dosage: String, form: MedicineForm, quantity: Int, timing: MealTiming, time: Date, memberName: String) {
        let newMed = Medicine(
            name: name,
            dosage: dosage,
            form: form,
            quantityPerDose: quantity,
            timing: timing,
            assignedMemberName: memberName,
            stockCount: 30,
            refillThreshold: 5
        )
        medicines.append(newMed)
        
        let newDose = ScheduledDose(
            medicineId: newMed.id,
            medicineName: "\(name) \(dosage)",
            doseDescription: "\(quantity) \(form.rawValue) • \(timing.rawValue)",
            scheduledTime: time,
            isTaken: false,
            assignedMemberName: memberName
        )
        todaySchedule.append(newDose)
        todaySchedule.sort(by: { $0.scheduledTime < $1.scheduledTime })
        
        NotificationManager.shared.scheduleMedicineReminder(
            medicineName: "\(name) \(dosage)",
            doseInfo: "\(quantity) \(form.rawValue) • \(timing.rawValue)",
            time: time
        )
        
        // Update member medication count
        if let memberIdx = familyMembers.firstIndex(where: { $0.name == memberName }) {
            familyMembers[memberIdx].medicationsCount += 1
        }
        
        HapticManager.shared.notification(type: .success)
        updateAdherence()
    }
    
    // MARK: - Vital Actions
    func addVital(type: VitalType, value: Double, secondary: Double? = nil, notes: String = "") {
        let calculatedStatus = VitalRecord.calculateStatus(type: type, value: value, secondary: secondary)
        let record = VitalRecord(
            type: type,
            value: value,
            secondaryValue: secondary,
            date: Date(),
            status: calculatedStatus,
            notes: notes
        )
        vitals.insert(record, at: 0)
        HapticManager.shared.impact(style: .medium)
    }
    
    func latestVital(for type: VitalType) -> VitalRecord? {
        return vitals.first(where: { $0.type == type })
    }
    
    func vitalsHistory(for type: VitalType, limit: Int = 7) -> [VitalRecord] {
        return Array(vitals.filter { $0.type == type }.prefix(limit).reversed())
    }
    
    // MARK: - Family Member Actions
    func addFamilyMember(name: String, relation: String, age: Int, condition: String, phone: String = "+91 98765 43210") {
        let member = FamilyMember(
            name: name,
            relation: relation,
            age: age,
            primaryCondition: condition,
            notes: "Regular routine checkup",
            medicationsCount: 0,
            phoneNumber: phone
        )
        familyMembers.append(member)
        HapticManager.shared.notification(type: .success)
    }
    
    func updateFamilyMember(_ member: FamilyMember) {
        if let index = familyMembers.firstIndex(where: { $0.id == member.id }) {
            familyMembers[index] = member
            HapticManager.shared.notification(type: .success)
        }
    }
    
    func deleteFamilyMember(id: UUID) {
        familyMembers.removeAll(where: { $0.id == id })
        HapticManager.shared.impact(style: .medium)
    }
    
    // MARK: - Emergency Contact Actions
    func addEmergencyContact(name: String, relationship: String, phone: String) {
        let contact = EmergencyContact(name: name, relationship: relationship, phone: phone, isPrimary: emergencyContacts.isEmpty)
        emergencyContacts.append(contact)
        HapticManager.shared.notification(type: .success)
    }
    
    func deleteEmergencyContact(id: UUID) {
        emergencyContacts.removeAll(where: { $0.id == id })
        HapticManager.shared.impact(style: .medium)
    }
    
    // MARK: - Adherence & Reports Calculation
    func overallAdherencePercentage() -> Double {
        let totalTaken = adherenceStats.reduce(0) { $0 + $1.takenCount }
        let totalDoses = adherenceStats.reduce(0) { $0 + $1.totalCount }
        guard totalDoses > 0 else { return 100.0 }
        return (Double(totalTaken) / Double(totalDoses)) * 100.0
    }
    
    func totalDosesSummary() -> (taken: Int, total: Int) {
        let taken = adherenceStats.reduce(0) { $0 + $1.takenCount }
        let total = adherenceStats.reduce(0) { $0 + $1.totalCount }
        return (taken, total)
    }
    
    func updateAdherence() {
        let takenCount = todaySchedule.filter { $0.isTaken }.count
        let totalCount = todaySchedule.count
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEE"
        let currentDayShort = weekdayFormatter.string(from: Date())
        
        if let todayIndex = adherenceStats.firstIndex(where: { $0.dayShort == currentDayShort || $0.dayShort == "Today" }) {
            adherenceStats[todayIndex].takenCount = takenCount
            adherenceStats[todayIndex].totalCount = max(totalCount, 1)
        } else if let lastIndex = adherenceStats.indices.last {
            adherenceStats[lastIndex].takenCount = takenCount
            adherenceStats[lastIndex].totalCount = max(totalCount, 1)
        }
    }
    
    // MARK: - Real Life Shareable Medical Report Generator
    func generateMedicalReportText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let summary = totalDosesSummary()
        let adherence = Int(overallAdherencePercentage())
        
        var report = """
        ==================================================
        🏥 MEDI ROUTINE - CLINICAL HEALTH & ADHERENCE REPORT
        Generated on: \(dateFormatter.string(from: Date()))
        ==================================================
        
        👤 PATIENT SUMMARY
        Name: \(userName)
        Blood Group: \(userBloodGroup)
        Email: \(userEmail)
        Known Allergies: \(userAllergies)
        Emergency Medical Notes: \(emergencyNotes)
        
        --------------------------------------------------
        📊 MEDICATION ADHERENCE OVERVIEW
        7-Day Adherence Rate: \(adherence)%
        Doses Completed: \(summary.taken) of \(summary.total)
        Current Status: \(adherence >= 85 ? "Excellent Compliance" : "Requires Attention")
        
        --------------------------------------------------
        💊 ACTIVE PRESCRIPTIONS & INVENTORY
        """
        
        for med in medicines {
            report += "\n• \(med.name) \(med.dosage) - \(med.form.rawValue.capitalized)\n  Timing: \(med.timing.rawValue) | Remaining: \(med.stockCount) pills"
            if med.isLowStock {
                report += " [⚠️ REFILL NEEDED]"
            }
        }
        
        report += "\n\n--------------------------------------------------"
        report += "\n🩺 LATEST CLINICAL VITALS TELEMETRY\n"
        
        for type in VitalType.allCases {
            if let rec = latestVital(for: type) {
                report += "• \(type.rawValue): \(rec.displayValue) \(type.unit) (\(rec.status))\n"
            }
        }
        
        report += """
        
        --------------------------------------------------
        🚨 EMERGENCY CONTACTS
        """
        for contact in emergencyContacts {
            report += "\n• \(contact.name) (\(contact.relationship)): \(contact.phone)"
        }
        
        report += "\n\n==================================================\nEnd of Report • Verified by Medi Routine Biotech"
        return report
    }
    
    // MARK: - Persistence (UserDefaults)
    private func savePreferences() {
        defaults.set(isDarkMode, forKey: "mr_isDarkMode")
        defaults.set(userName, forKey: "mr_userName")
        defaults.set(userEmail, forKey: "mr_userEmail")
        defaults.set(userBloodGroup, forKey: "mr_userBloodGroup")
        defaults.set(userAllergies, forKey: "mr_userAllergies")
        defaults.set(emergencyNotes, forKey: "mr_emergencyNotes")
        defaults.set(currentLanguage.rawValue, forKey: "mr_language")
    }
    
    private func saveMedicines() {
        if let data = try? JSONEncoder().encode(medicines) {
            defaults.set(data, forKey: "mr_medicines")
        }
    }
    
    private func saveSchedule() {
        if let data = try? JSONEncoder().encode(todaySchedule) {
            defaults.set(data, forKey: "mr_todaySchedule")
        }
    }
    
    private func saveFamily() {
        if let data = try? JSONEncoder().encode(familyMembers) {
            defaults.set(data, forKey: "mr_familyMembers")
        }
    }
    
    private func saveVitals() {
        if let data = try? JSONEncoder().encode(vitals) {
            defaults.set(data, forKey: "mr_vitals")
        }
    }
    
    private func saveContacts() {
        if let data = try? JSONEncoder().encode(emergencyContacts) {
            defaults.set(data, forKey: "mr_emergencyContacts")
        }
    }
    
    private func saveStats() {
        if let data = try? JSONEncoder().encode(adherenceStats) {
            defaults.set(data, forKey: "mr_adherenceStats")
        }
    }
    
    func loadData() {
        if defaults.object(forKey: "mr_isDarkMode") != nil {
            isDarkMode = defaults.bool(forKey: "mr_isDarkMode")
        }
        if let langStr = defaults.string(forKey: "mr_language"), let lang = AppLanguage(rawValue: langStr) {
            currentLanguage = lang
        }
        if let name = defaults.string(forKey: "mr_userName") { userName = name }
        if let email = defaults.string(forKey: "mr_userEmail") { userEmail = email }
        if let blood = defaults.string(forKey: "mr_userBloodGroup") { userBloodGroup = blood }
        if let all = defaults.string(forKey: "mr_userAllergies") { userAllergies = all }
        if let notes = defaults.string(forKey: "mr_emergencyNotes") { emergencyNotes = notes }
        
        var loadedMedicines = false
        if let medData = defaults.data(forKey: "mr_medicines"),
           let meds = try? JSONDecoder().decode([Medicine].self, from: medData), !meds.isEmpty {
            medicines = meds
            loadedMedicines = true
        }
        
        var loadedSchedule = false
        if let schedData = defaults.data(forKey: "mr_todaySchedule"),
           let sched = try? JSONDecoder().decode([ScheduledDose].self, from: schedData), !sched.isEmpty {
            todaySchedule = sched
            loadedSchedule = true
        }
        
        var loadedFamily = false
        if let famData = defaults.data(forKey: "mr_familyMembers"),
           let fam = try? JSONDecoder().decode([FamilyMember].self, from: famData), !fam.isEmpty {
            familyMembers = fam
            loadedFamily = true
        }
        
        var loadedVitals = false
        if let vitData = defaults.data(forKey: "mr_vitals"),
           let vit = try? JSONDecoder().decode([VitalRecord].self, from: vitData), !vit.isEmpty {
            vitals = vit
            loadedVitals = true
        }
        
        var loadedContacts = false
        if let conData = defaults.data(forKey: "mr_emergencyContacts"),
           let con = try? JSONDecoder().decode([EmergencyContact].self, from: conData), !con.isEmpty {
            emergencyContacts = con
            loadedContacts = true
        }
        
        var loadedStats = false
        if let statData = defaults.data(forKey: "mr_adherenceStats"),
           let stats = try? JSONDecoder().decode([DayDoseStat].self, from: statData), !stats.isEmpty {
            adherenceStats = stats
            loadedStats = true
        }
        
        if !loadedMedicines || !loadedSchedule || !loadedFamily || !loadedVitals || !loadedContacts || !loadedStats {
            loadMockData()
        }
    }
    
    func loadMockData() {
        let cal = Calendar.current
        let now = Date()
        
        let date8AM = cal.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        let date1230PM = cal.date(bySettingHour: 12, minute: 30, second: 0, of: now) ?? now
        let date6PM = cal.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        let date930PM = cal.date(bySettingHour: 21, minute: 30, second: 0, of: now) ?? now
        
        let med1 = Medicine(name: "Paracetamol", dosage: "500 mg", form: .tablet, quantityPerDose: 1, timing: .afterFood, assignedMemberName: "Ayush", stockCount: 24, refillThreshold: 5)
        let med2 = Medicine(name: "Vitamin D3", dosage: "1000 IU", form: .capsule, quantityPerDose: 1, timing: .afterFood, assignedMemberName: "Ayush", stockCount: 15, refillThreshold: 5)
        let med3 = Medicine(name: "Atorvastatin", dosage: "10 mg", form: .tablet, quantityPerDose: 1, timing: .beforeSleep, assignedMemberName: "Ayush", stockCount: 18, refillThreshold: 5)
        let med4 = Medicine(name: "Metformin", dosage: "500 mg", form: .tablet, quantityPerDose: 1, timing: .afterFood, assignedMemberName: "Rohan", stockCount: 4, refillThreshold: 5)
        
        medicines = [med1, med2, med3, med4]
        
        todaySchedule = [
            ScheduledDose(medicineId: med1.id, medicineName: "Paracetamol 500 mg", doseDescription: "1 tablet • After food", scheduledTime: date8AM, isTaken: true, takenAt: date8AM, assignedMemberName: "Ayush"),
            ScheduledDose(medicineId: med2.id, medicineName: "Vitamin D3 1000 IU", doseDescription: "1 capsule • After food", scheduledTime: date1230PM, isTaken: false, assignedMemberName: "Ayush"),
            ScheduledDose(medicineId: med3.id, medicineName: "Atorvastatin 10 mg", doseDescription: "1 tablet • Before sleep", scheduledTime: date6PM, isTaken: false, assignedMemberName: "Ayush"),
            ScheduledDose(medicineId: med4.id, medicineName: "Metformin 500 mg", doseDescription: "1 tablet • After dinner", scheduledTime: date930PM, isTaken: false, assignedMemberName: "Rohan")
        ]
        
        let sunitaVitals = [
            VitalRecord(type: .bloodPressure, value: 118, secondaryValue: 76, status: "Normal"),
            VitalRecord(type: .heartRate, value: 76, status: "Normal"),
            VitalRecord(type: .bloodSugar, value: 95, status: "Normal")
        ]
        
        familyMembers = [
            FamilyMember(name: "Rohan", relation: "Father", age: 58, primaryCondition: "Diabetes", avatarColorHex: "3B82F6", notes: "Low sugar diet prescribed", medicationsCount: 2, phoneNumber: "+91 98200 11223"),
            FamilyMember(name: "Sunita", relation: "Mother", age: 52, primaryCondition: "BP", avatarColorHex: "EC4899", notes: "Allergic to penicillin", medicationsCount: 3, phoneNumber: "+91 98300 44556", vitals: sunitaVitals),
            FamilyMember(name: "Ayush", relation: "You", age: 20, primaryCondition: "General", avatarColorHex: "10B981", notes: "Regular routine", medicationsCount: 3, phoneNumber: "+91 98765 43210"),
            FamilyMember(name: "Aarav", relation: "Brother", age: 10, primaryCondition: "Allergy", avatarColorHex: "F59E0B", notes: "Avoid cold drinks and ice", medicationsCount: 1, phoneNumber: "+91 98400 77889")
        ]
        
        vitals = [
            VitalRecord(type: .heartRate, value: 72, status: "Normal"),
            VitalRecord(type: .heartRate, value: 75, date: Date().addingTimeInterval(-86400), status: "Normal"),
            VitalRecord(type: .heartRate, value: 70, date: Date().addingTimeInterval(-172800), status: "Normal"),
            VitalRecord(type: .heartRate, value: 78, date: Date().addingTimeInterval(-259200), status: "Normal"),
            VitalRecord(type: .heartRate, value: 72, date: Date().addingTimeInterval(-345600), status: "Normal"),
            
            VitalRecord(type: .bloodPressure, value: 118, secondaryValue: 76, status: "Normal"),
            VitalRecord(type: .bloodPressure, value: 120, secondaryValue: 78, date: Date().addingTimeInterval(-86400), status: "Normal"),
            VitalRecord(type: .bloodPressure, value: 116, secondaryValue: 74, date: Date().addingTimeInterval(-172800), status: "Normal"),
            
            VitalRecord(type: .bloodSugar, value: 92, status: "Normal"),
            VitalRecord(type: .bloodSugar, value: 96, date: Date().addingTimeInterval(-86400), status: "Normal"),
            VitalRecord(type: .bloodSugar, value: 89, date: Date().addingTimeInterval(-172800), status: "Normal"),
            
            VitalRecord(type: .temperature, value: 36.6, status: "Normal"),
            VitalRecord(type: .steps, value: 8240, status: "Goal Met"),
            VitalRecord(type: .sleep, value: 7.8, status: "Restful"),
            VitalRecord(type: .weight, value: 68.0, status: "Logged")
        ]
        
        adherenceStats = [
            DayDoseStat(dayShort: "Mon", takenCount: 3, totalCount: 3),
            DayDoseStat(dayShort: "Tue", takenCount: 3, totalCount: 3),
            DayDoseStat(dayShort: "Wed", takenCount: 2, totalCount: 3),
            DayDoseStat(dayShort: "Thu", takenCount: 3, totalCount: 3),
            DayDoseStat(dayShort: "Fri", takenCount: 3, totalCount: 3),
            DayDoseStat(dayShort: "Sat", takenCount: 2, totalCount: 3),
            DayDoseStat(dayShort: "Sun", takenCount: 3, totalCount: 3)
        ]
        
        emergencyContacts = [
            EmergencyContact(name: "National Emergency Helpline", relationship: "Official", phone: "112", isPrimary: true),
            EmergencyContact(name: "Ambulance Dispatch", relationship: "Medical", phone: "108", isPrimary: false),
            EmergencyContact(name: "Rohan (Father)", relationship: "Family", phone: "+91 98200 11223", isPrimary: false),
            EmergencyContact(name: "Dr. Sharma (Cardiologist)", relationship: "Family Physician", phone: "+91 98111 22334", isPrimary: false)
        ]
    }
}

extension ScheduledDose {
    func quantityPerDose(fallback: Int = 1) -> Int {
        let scanner = Scanner(string: doseDescription)
        var count: Int = 0
        if scanner.scanInt(&count), count > 0 {
            return count
        }
        return fallback
    }
}
