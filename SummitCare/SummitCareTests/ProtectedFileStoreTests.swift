// SummitCareTests/ProtectedFileStoreTests.swift (Solution 11)
import Foundation
import Testing
@testable import SummitCare

@Test func storedFilesUseCompleteProtectionAndSkipBackup() throws {
    let store = ProtectedFileStore(root: URL.temporaryDirectory.appending(path: UUID().uuidString))
    let url = try store.write(Data("probe".utf8), named: "probe.bin")

    let attributes = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
    #expect(attributes[.protectionKey] as? FileProtectionType == .complete)
    let values = try url.resourceValues(forKeys: [.isExcludedFromBackupKey])
    #expect(values.isExcludedFromBackup == true)

    try store.purgeAll()
}
