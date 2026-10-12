// SummitCare/Features/Settings/ContactPreferencesModel.swift (Solution 21)
// Holds the form state for ContactPreferencesView. The companion API does not
// include the preferences endpoint, so saving is left to the reader.
import Foundation
import Observation

@Observable @MainActor
final class ContactPreferencesModel {
    var confidential = false
    var alternateEmail = ""
    var allowMessagePreview = false
}
