// SummitCare/Support/SensitivePasteboard.swift (Solution 12)
import UIKit
import UniformTypeIdentifiers

@MainActor
enum SensitivePasteboard {
    static func copy(_ text: String, expiresAfter seconds: TimeInterval = 60) {
        UIPasteboard.general.setItems(
            [[UTType.plainText.identifier: text]],
            options: [.localOnly: true, .expirationDate: Date.now.addingTimeInterval(seconds)])
    }
}
