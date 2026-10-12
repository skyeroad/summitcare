// SummitCare/Networking/AllowedHosts.swift (Solution 23)
import Foundation

enum OutboundHostError: Error {
    case uncoveredHost(String)
}

enum AllowedHosts {
    /// Hosts that may receive PHI. Each maps to a BAA-covered entry in config/vendors.yml.
    static let phi: Set<String> = ["api.summitcare.example"]

    static func check(_ url: URL) throws(OutboundHostError) {
        guard let host = url.host(), phi.contains(host) else {
            throw .uncoveredHost(url.host() ?? "none")
        }
    }
}
