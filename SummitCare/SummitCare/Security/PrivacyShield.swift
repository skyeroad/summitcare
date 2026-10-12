// SummitCare/Security/PrivacyShield.swift (Solution 5; reused by Solution 12)
import SwiftUI

struct PrivacyShield: ViewModifier {
    @Environment(SessionManager.self) private var session
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        let shielded = scenePhase != .active || session.state != .active
        content
            .accessibilityHidden(shielded)
            .overlay { if shielded { LockScreen() } }
    }
}

extension View {
    func privacyShield() -> some View { modifier(PrivacyShield()) }
}
