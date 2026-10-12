// SummitCare/Models/CachedAppointment.swift: the one thing cached on the device
// (Solution 11). Times and status only; never the visit reason.
import Foundation
import SwiftData

@Model
final class CachedAppointment {
    @Attribute(.unique) var appointmentID: Int
    var startsAt: Date
    var endsAt: Date
    var status: String

    init(appointmentID: Int, startsAt: Date, endsAt: Date, status: String) {
        self.appointmentID = appointmentID
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.status = status
    }
}
