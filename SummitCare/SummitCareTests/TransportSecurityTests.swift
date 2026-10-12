// SummitCareTests/TransportSecurityTests.swift (Solution 10)
import Foundation
import Testing

@Test func atsIsNotWeakened() {
    let ats = Bundle.main.object(forInfoDictionaryKey: "NSAppTransportSecurity") as? [String: Any]
    #expect(ats?["NSAllowsArbitraryLoads"] as? Bool != true)
    #expect(ats?["NSExceptionDomains"] == nil)
}
