// SummitCare/Models/Message.swift
import Foundation

struct Message: Codable, Sendable, Identifiable, Hashable {
    let id: Int
    let patientID: Patient.ID
    let senderID: Int
    let body: String
    let createdAt: Date
    let readAt: Date?

    enum CodingKeys: String, CodingKey {   // keys after .convertFromSnakeCase
        case id, patientID = "patientId", senderID = "senderId", body, createdAt, readAt
    }
}
