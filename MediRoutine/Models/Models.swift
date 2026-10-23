import Foundation
import SwiftUI

// MARK: - Medicine Form
enum MedicineForm: String, CaseIterable, Codable {
    case tablet = "tablet"
    case capsule = "capsule"
    case syrup = "syrup"
    case injection = "injection"
    case drops = "drops"
    case inhaler = "inhaler"
    
    var iconName: String {
        switch self {
        case .tablet: return "pills.fill"
        case .capsule: return "capsule.fill"
        case .syrup: return "cross.vial.fill"
        case .injection: return "syringe.fill"
        case .drops: return "drop.fill"
        case .inhaler: return "wind"
        }
    }
}

// MARK: - Meal Timing / Frequency
enum MealTiming: String, CaseIterable, Codable {
    case afterFood = "After food"
    case beforeFood = "Before food"
    case withFood = "With food"
    case emptyStomach = "Empty stomach"
    case beforeSleep = "Before sleep"
    case anytime = "Anytime"
}

// MARK: - Medicine Model
struct Medicine: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var dosage: String               // e.g. "500 mg", "1000 IU", "10 mg"
    var form: MedicineForm = .tablet
    var quantityPerDose: Int = 1      // e.g. 1 tablet, 1 capsule
    var timing: MealTiming = .afterFood
    var assignedMemberId: UUID?       // Which family member this belongs to
    var stockCount: Int = 30         // Remaining pills
    var refillThreshold: Int = 5     // Alert when stock is low
    var notes: String = ""
    var colorHex: String = "E53950"  // Primary accent
    
    var doseDescription: String {
        "\(quantityPerDose) \(form.rawValue) • \(timing.rawValue)"
    }
}

// MARK: - Dose Reminder
struct ScheduledDose: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var medicineId: UUID
    var medicineName: String
    var doseDescription: String
    var scheduledTime: Date          // Date component representing time of day
    var isTaken: Bool = false
    var takenAt: Date? = nil
    var assignedMemberName: String = "Ayush"
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: scheduledTime)
    }
}

// MARK: - Vital Types
enum VitalType: String, CaseIterable, Codable {
    case heartRate = "Heart Rate"
    case bloodPressure = "Blood Pressure"
    case bloodSugar = "Blood Sugar"
    case temperature = "Temperature"
    case steps = "Steps"
    case sleep = "Sleep"
    case weight = "Weight"
    
    var iconName: String {
        switch self {
        case .heartRate: return "heart.fill"
        case .bloodPressure: return "gauge.with.needle.fill"
        case .bloodSugar: return "drop.fill"
        case .temperature: return "thermometer.medium"
        case .steps: return "figure.walk"
        case .sleep: return "moon.zzz.fill"
        case .weight: return "scalemass.fill"
        }
    }
    
    var unit: String {
        switch self {
        case .heartRate: return "bpm"
        case .bloodPressure: return "mmHg"
        case .bloodSugar: return "mg/dL"
        case .temperature: return "°C"
        case .steps: return "steps"
        case .sleep: return "hrs"
        case .weight: return "kg"
        }
    }
    
    var color: Color {
        switch self {
        case .heartRate: return Color(red: 0.95, green: 0.25, blue: 0.35)
        case .bloodPressure: return Color(red: 0.85, green: 0.2, blue: 0.4)
        case .bloodSugar: return Color(red: 0.2, green: 0.55, blue: 0.95)
        case .temperature: return Color(red: 0.2, green: 0.75, blue: 0.45)
        case .steps: return Color(red: 0.95, green: 0.55, blue: 0.15)
        case .sleep: return Color(red: 0.55, green: 0.35, blue: 0.95)
        case .weight: return Color(red: 0.1, green: 0.7, blue: 0.8)
        }
    }
}

// MARK: - Vital Record
struct VitalRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var type: VitalType
    var value: Double
    var secondaryValue: Double? = nil // For BP diastolic (e.g. 118 / 76)
    var date: Date = Date()
    var status: String = "Normal"     // "Normal", "Elevated", "Low"
    
    var displayValue: String {
        switch type {
        case .bloodPressure:
            if let sec = secondaryValue {
                return "\(Int(value))/\(Int(sec))"
            }
            return "\(Int(value))"
        case .temperature:
            return String(format: "%.1f", value)
        case .heartRate, .steps:
            return "\(Int(value))"
        case .bloodSugar, .weight:
            return String(format: "%.0f", value)
        case .sleep:
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Family Member
struct FamilyMember: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var relation: String             // "Father", "Mother", "You", "Brother"
    var age: Int
    var primaryCondition: String     // "Diabetes", "BP", "General", "Allergy"
    var avatarSystemName: String = "person.crop.circle.fill"
    var avatarColorHex: String = "E53950"
    var notes: String = ""
    var medicationsCount: Int = 1
    var vitals: [VitalRecord] = []
    
    var subtitle: String {
        "Age \(age) • \(primaryCondition)"
    }
    
    var displayNameWithRelation: String {
        "\(name) (\(relation))"
    }
}

// MARK: - Emergency Contact
struct EmergencyContact: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var relationship: String
    var phone: String
    var isPrimary: Bool = false
}

// MARK: - Day Dose Stat (for reports)
struct DayDoseStat: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var dayShort: String   // "Mon", "Tue", etc.
    var takenCount: Int
    var totalCount: Int
    
    var adherencePercentage: Double {
        guard totalCount > 0 else { return 100 }
        return (Double(takenCount) / Double(totalCount)) * 100
    }
}
