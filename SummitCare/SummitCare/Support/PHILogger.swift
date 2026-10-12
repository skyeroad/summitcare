// SummitCare/Support/PHILogger.swift (Solution 15)
import os

enum PHILogger {
    static let network = Logger(subsystem: "com.summitcare.app", category: "network")
    static let records = Logger(subsystem: "com.summitcare.app", category: "records")
}
