// SummitCare/Features/LabResults/LabResultActivity.swift (Solution 12)
import Foundation

enum LabResultActivity {
    static let type = "com.summitcare.app.viewLabResult"

    static func configure(_ activity: NSUserActivity, labResultID: Int) {
        activity.isEligibleForSearch = false
        activity.isEligibleForPrediction = false
        activity.isEligibleForHandoff = false
        activity.userInfo = ["labResultID": labResultID] // an ID, never values
    }
}
