// SummitCare/Features/Records/RecordsModel.swift (Solution 18)
import Foundation
import Observation

@Observable @MainActor
final class RecordsModel {
    enum Phase: Equatable { case idle, requested, downloading, ready(URL), failed(String) }

    private(set) var phase: Phase = .idle
    private let api: APIClient
    private let fileStore: ProtectedFileStore

    init(api: APIClient, fileStore: ProtectedFileStore = .shared) {
        self.api = api
        self.fileStore = fileStore
    }

    func requestExport(for patientID: Patient.ID) async {
        do {
            _ = try await api.send(try Endpoints.requestRecordExport(patientID: patientID), as: RecordExportReceipt.self)
            phase = .requested
            await Analytics.shared.record(.recordExportRequested)
        } catch {
            phase = .failed("We couldn't send your request. Please try again.")
        }
    }

    func download(_ file: RecordExportFile, for patientID: Patient.ID) async {
        phase = .downloading
        do {
            let data = try await api.downloadRecordExport(patientID: patientID, file: file)
            let url = try fileStore.write(data, named: file.filename)
            phase = .ready(url)
        } catch {
            phase = .failed("The download didn't finish. Please try again.")
        }
    }

    func removeLocalCopy() {
        if case .ready(let url) = phase { try? fileStore.remove(url) }
        phase = .idle
    }
}
