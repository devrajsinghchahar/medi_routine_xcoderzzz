import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Codable {
    case english = "English"
    case hindi = "हिंदी (Hindi)"
}

class DataStore: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isDarkMode: Bool = false
    @Published var currentLanguage: AppLanguage = .english
    
    // User Profile
    @Published var userName: String = "Ayush"
    @Published var userEmail: String = "ayush@mediroutine.com"
    @Published var userBloodGroup: String = "O+"
    @Published var userAllergies: String = "Peanuts, Dust"
    @Published var emergencyNotes: String = "Carry inhaler during winter"
    
    // Core Data collections
    @Published var medicines: [Medicine] = []
    @Published var todaySchedule: [ScheduledDose] = []
    @Published var familyMembers: [FamilyMember] = []
    @Published var vitals: [VitalRecord] = []
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var adherenceStats: [DayDoseStat] = []
    
    // Quick banners / unread notifications
    @Published var unreadNotificationsCount: Int = 2
    @Published var showingAddMedicineSheet: Bool = false
    @Published var showingSOSSheet: Bool = false
    @Published var showingLogVitalSheet: Bool = false
    @Published var showingAddMemberSheet: Bool = false
    
    init() {
        loadMockData()
        
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
    
    // Localized string helper
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
    
    func toggleDoseTaken(doseId: UUID) {
        if let index = todaySchedule.firstIndex(where: { $0.id == doseId }) {
            todaySchedule[index].isTaken.toggle()
            todaySchedule[index].takenAt = todaySchedule[index].isTaken ? Date() : nil
            HapticManager.shared.notification(type: .success)
            updateAdherence()
        }
    }
    
    func addMedicine(name: String, dosage: String, form: MedicineForm, quantity: Int, timing: MealTiming, time: Date, memberName: String) {
        let newMed = Medicine(
            name: name,
            dosage: dosage,
            form: form,
            quantityPerDose: quantity,
            timing: timing,
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
        
        HapticManager.shared.notification(type: .success)
    }
    
    func addVital(type: VitalType, value: Double, secondary: Double? = nil) {
        let record = VitalRecord(type: type, value: value, secondaryValue: secondary, date: Date(), status: "Normal")
        vitals.insert(record, at: 0)
        HapticManager.shared.impact(style: .medium)
    }
    
    func addFamilyMember(name: String, relation: String, age: Int, condition: String) {
        let member = FamilyMember(
            name: name,
            relation: relation,
            age: age,
            primaryCondition: condition,
            notes: "Regular checkups",
            medicationsCount: 1
        )
        familyMembers.append(member)
        HapticManager.shared.notification(type: .success)
    }
    
    private func updateAdherence() {
        let takenCount = todaySchedule.filter { $0.isTaken }.count
        let totalCount = todaySchedule.count
        if let todayIndex = adherenceStats.firstIndex(where: { $0.dayShort == "Tue" || $0.dayShort == "Today" }) {
            adherenceStats[todayIndex].takenCount = takenCount
            adherenceStats[todayIndex].totalCount = totalCount
        }
    }
    
    func loadMockData() {
        // Today's schedule exactly matching the mockup screenshot:
        // 08:00 AM Paracetamol 500 mg (1 tablet • After food) [Taken]
        // 12:30 PM Vitamin D3 1000 IU (1 capsule • After food) [Pending]
        // 06:00 PM Atorvastatin 10 mg (1 tablet • Before sleep) [Pending]
        
        let cal = Calendar.current
        let now = Date()
        
        var date8AM = cal.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        var date1230PM = cal.date(bySettingHour: 12, minute: 30, second: 0, of: now) ?? now
        var date6PM = cal.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        
        let med1 = Medicine(name: "Paracetamol", dosage: "500 mg", form: .tablet, quantityPerDose: 1, timing: .afterFood, stockCount: 24, refillThreshold: 5)
        let med2 = Medicine(name: "Vitamin D3", dosage: "1000 IU", form: .capsule, quantityPerDose: 1, timing: .afterFood, stockCount: 15, refillThreshold: 5)
        let med3 = Medicine(name: "Atorvastatin", dosage: "10 mg", form: .tablet, quantityPerDose: 1, timing: .beforeSleep, stockCount: 20, refillThreshold: 5)
        
        medicines = [med1, med2, med3]
        
        todaySchedule = [
            ScheduledDose(medicineId: med1.id, medicineName: "Paracetamol 500 mg", doseDescription: "1 tablet • After food", scheduledTime: date8AM, isTaken: true, takenAt: date8AM, assignedMemberName: "Ayush"),
            ScheduledDose(medicineId: med2.id, medicineName: "Vitamin D3 1000 IU", doseDescription: "1 capsule • After food", scheduledTime: date1230PM, isTaken: false, assignedMemberName: "Ayush"),
            ScheduledDose(medicineId: med3.id, medicineName: "Atorvastatin 10 mg", doseDescription: "1 tablet • Before sleep", scheduledTime: date6PM, isTaken: false, assignedMemberName: "Ayush")
        ]
        
        // Family Members matching the mockup screenshot:
        // Rohan (Father), Age 58 • Diabetes (2 meds)
        // Sunita (Mother), Age 52 • BP (3 meds)
        // Ayush (You), Age 20 • General (1 med)
        // Aarav (Brother), Age 10 • Allergy (1 med)
        let sunitaVitals = [
            VitalRecord(type: .bloodPressure, value: 118, secondaryValue: 76, status: "Normal"),
            VitalRecord(type: .heartRate, value: 76, status: "Normal"),
            VitalRecord(type: .bloodSugar, value: 95, status: "Normal")
        ]
        
        familyMembers = [
            FamilyMember(name: "Rohan", relation: "Father", age: 58, primaryCondition: "Diabetes", avatarColorHex: "3B82F6", notes: "Low sugar diet prescribed", medicationsCount: 2),
            FamilyMember(name: "Sunita", relation: "Mother", age: 52, primaryCondition: "BP", avatarColorHex: "EC4899", notes: "Allergic to penicillin", medicationsCount: 3, vitals: sunitaVitals),
            FamilyMember(name: "Ayush", relation: "You", age: 20, primaryCondition: "General", avatarColorHex: "10B981", notes: "Regular routine", medicationsCount: 1),
            FamilyMember(name: "Aarav", relation: "Brother", age: 10, primaryCondition: "Allergy", avatarColorHex: "F59E0B", notes: "Avoid cold items", medicationsCount: 1)
        ]
        
        // Vitals matching the Health Tracker screen:
        // Heart Rate 72 bpm (Normal)
        // Blood Pressure 118/76 mmHg (Normal)
        // Blood Sugar 92 mg/dL (Normal)
        // Temperature 36.6 °C (Normal)
        vitals = [
            VitalRecord(type: .heartRate, value: 72, status: "Normal"),
            VitalRecord(type: .bloodPressure, value: 118, secondaryValue: 76, status: "Normal"),
            VitalRecord(type: .bloodSugar, value: 92, status: "Normal"),
            VitalRecord(type: .temperature, value: 36.6, status: "Normal"),
            VitalRecord(type: .steps, value: 6840, status: "Normal"),
            VitalRecord(type: .sleep, value: 7.5, status: "Normal"),
            VitalRecord(type: .weight, value: 68.0, status: "Normal")
        ]
        
        // Reports bar chart data
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
            EmergencyContact(name: "Emergency Services", relationship: "Official", phone: "112", isPrimary: true),
            EmergencyContact(name: "Ambulance", relationship: "Medical", phone: "108", isPrimary: false),
            EmergencyContact(name: "Rohan (Father)", relationship: "Family", phone: "+91 98765 43210", isPrimary: false),
            EmergencyContact(name: "Dr. Sharma", relationship: "Family Physician", phone: "+91 98111 22334", isPrimary: false)
        ]
    }
}
