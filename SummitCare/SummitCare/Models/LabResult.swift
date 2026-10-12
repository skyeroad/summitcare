// SummitCare/Models/LabResult.swift
import Foundation

struct LabResult: Codable, Sendable, Identifiable, Hashable {
    let id: Int
    let patientID: Patient.ID
    let testCode: String?   // LOINC
    let testName: String?
    let value: String?
    let unit: String?
    let referenceRange: String?
    let resultedAt: Date
    let notes: String?      // clinicians only (Solution 4)

    enum CodingKeys: String, CodingKey {   // keys after .convertFromSnakeCase
        case id, patientID = "patientId", testCode, testName, value, unit, referenceRange, resultedAt, notes
    }
}
