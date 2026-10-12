// SummitCareTests/SideChannelTests.swift (Solution 12)
import Foundation
import Testing
@testable import SummitCare

@Test func labResultActivityIsNotPublic() {
    let activity = NSUserActivity(activityType: LabResultActivity.type)
    LabResultActivity.configure(activity, labResultID: 42)
    #expect(activity.isEligibleForSearch == false)
    #expect(activity.isEligibleForHandoff == false)
    #expect(activity.isEligibleForPrediction == false)
}
