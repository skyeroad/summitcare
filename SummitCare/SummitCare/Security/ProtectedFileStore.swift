// SummitCare/Security/ProtectedFileStore.swift (Solution 11)
import Foundation

struct ProtectedFileStore: Sendable {
    let root: URL

    static let shared = ProtectedFileStore(
        root: URL.applicationSupportDirectory.appending(path: "Protected", directoryHint: .isDirectory))

    func write(_ data: Data, named name: String) throws -> URL {
        try prepareRoot()
        let url = root.appending(path: name)
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        try excludeFromBackup(url)
        return url
    }

    func importFile(at temporaryURL: URL, named name: String) throws -> URL {
        try prepareRoot()
        let destination = root.appending(path: name)
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: temporaryURL, to: destination)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete],
                                              ofItemAtPath: destination.path(percentEncoded: false))
        try excludeFromBackup(destination)
        return destination
    }
}

extension ProtectedFileStore {
    func purgeAll() throws {
        guard FileManager.default.fileExists(atPath: root.path(percentEncoded: false)) else { return }
        try FileManager.default.removeItem(at: root)
    }

    func remove(_ url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    private func prepareRoot() throws {
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete])
        try excludeFromBackup(root)
    }

    private func excludeFromBackup(_ url: URL) throws {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var target = url
        try target.setResourceValues(values)
    }
}
