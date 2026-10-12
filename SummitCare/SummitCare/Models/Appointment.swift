// SummitCare/Models/Appointment.swift
import Foundation

struct Appointment: Codable, Sendable, Identifiable, Hashable {
    let id: Int
    let patientID: Patient.ID
    let clinicianID: Int
    let startsAt: Date
    let endsAt: Date
    let status: String
    let reason: String?   // absent for front desk and billing (Solution 4)

    enum CodingKeys: String, CodingKey {   // keys after .convertFromSnakeCase
        case id, patientID = "patientId", clinicianID = "clinicianId", startsAt, endsAt, status, reason
    }
}
