// SummitCare/Models/Patient.swift: value types decoded from the API (Solution 4
// decides which fields arrive for each role, so most are optional).
import Foundation

struct Patient: Codable, Sendable, Identifiable, Hashable {
    let id: Int
    let mrn: String?
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?   // "1984-03-12"; a calendar date, not an instant
    let phone: String?
    let email: String?

    var displayName: String { [firstName, lastName].compactMap(\.self).joined(separator: " ") }
}
