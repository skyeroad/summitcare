// SummitCareTests/SessionManagerTests.swift (Solution 5)
import SwiftUI
import Testing
@testable import SummitCare

@MainActor struct SessionManagerTests {
    @Test func locksAfterBackgroundGracePeriod() {
        let manager = SessionManager(state: .active, idleLimit: 300, backgroundGrace: 30)
        let start = Date.now
        manager.recordActivity(at: start)
        manager.scenePhaseChanged(to: .background, at: start)
        manager.scenePhaseChanged(to: .active, at: start.addingTimeInterval(31))
        #expect(manager.state == .locked)
    }

    // Not in the book.
    @Test func locksAfterIdleLimit() {
        let manager = SessionManager(state: .active, idleLimit: 300, backgroundGrace: 30)
        let start = Date.now
        manager.recordActivity(at: start)
        manager.checkIdle(at: start.addingTimeInterval(299))
        #expect(manager.state == .active)
        manager.checkIdle(at: start.addingTimeInterval(300))
        #expect(manager.state == .locked)
    }
}
