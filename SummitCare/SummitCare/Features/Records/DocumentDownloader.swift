// SummitCare/Features/Records/DocumentDownloader.swift (Solution 9)
import Foundation
import UniformTypeIdentifiers

struct DocumentDownloadTicket: Decodable, Sendable {
    let url: URL
    let expiresAt: Date
    let contentType: String
}

actor DocumentDownloader {
    private let api: APIClient
    private let store: ProtectedFileStore
    private let session = URLSession(configuration: .ephemeral)

    init(api: APIClient, store: ProtectedFileStore = .shared) {
        self.api = api
        self.store = store
    }

    func download(patientID: Int, documentID: Int) async throws -> URL {
        let ticket = try await api.send(Endpoints.document(patientID: patientID, id: documentID),
                                        as: DocumentDownloadTicket.self)
        let (tempURL, response) = try await session.download(from: ticket.url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            try? FileManager.default.removeItem(at: tempURL)
            throw URLError(.badServerResponse)
        }
        let ext = UTType(mimeType: ticket.contentType)?.preferredFilenameExtension ?? "bin"
        return try store.importFile(at: tempURL, named: "\(UUID().uuidString).\(ext)")
    }
}
