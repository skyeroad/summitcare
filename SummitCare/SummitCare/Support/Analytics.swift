// SummitCare/Support/Analytics.swift (Solution 26)
import Foundation

/// The complete list of analytics events. No free-form strings, no associated values.
enum AnalyticsEvent: String, CaseIterable, Sendable {
    case appLaunched = "app_launched"
    case signInSucceeded = "sign_in_succeeded"
    case messagesOpened = "messages_opened"
    case messageSent = "message_sent"
    case labResultsOpened = "lab_results_opened"
    case recordExportRequested = "record_export_requested"
}

actor Analytics {
    static let shared = Analytics()
    private var counts: [AnalyticsEvent: Int] = [:]
    private let session = URLSession(configuration: .ephemeral)

    func record(_ event: AnalyticsEvent) {
        counts[event, default: 0] += 1
    }

    func flush() async {
        guard !counts.isEmpty,
              let url = URL(string: "https://api.summitcare.example/api/v1/analytics_events") else { return }
        let batch = Dictionary(uniqueKeysWithValues: counts.map { ($0.key.rawValue, $0.value) })
        counts = [:]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["counts": batch])
        _ = try? await session.data(for: request)   // no bearer token: counts aren't tied to a user
    }
}
