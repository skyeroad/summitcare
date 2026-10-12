// SummitCareTests/AnalyticsEventTests.swift (Solution 26)
import Testing
@testable import SummitCare

struct AnalyticsEventTests {
    @Test func eventNamesAreFixedSnakeCase() {
        for event in AnalyticsEvent.allCases {
            #expect(event.rawValue.wholeMatch(of: /[a-z]+(_[a-z]+)*/) != nil)
        }
    }

    @Test func allowlistMatchesServer() {
        let server: Set = ["app_launched", "sign_in_succeeded", "messages_opened",
                           "message_sent", "lab_results_opened", "record_export_requested"]
        #expect(Set(AnalyticsEvent.allCases.map(\.rawValue)) == server)
    }
}
