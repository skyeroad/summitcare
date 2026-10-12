// SummitCare/Features/LabResults/LabResultsModel.swift
import Foundation
import Observation

@Observable @MainActor
final class LabResultsModel {
    private(set) var results: [LabResult] = []
    private(set) var failed = false

    func load(patientID: Patient.ID, using model: AppModel) async {
        do {
            let results = try await model.apiClient.send(Endpoints.labResults(patientID: patientID),
                                                         as: [LabResult].self)
            self.results = results
            failed = false
            didLoad(results, patientID: patientID)
        } catch {
            failed = true
            await model.handle(error)
        }
    }

    // Solution 15: counts are public; identifiers are hashed; values never logged.
    func didLoad(_ results: [LabResult], patientID: Int) {
        PHILogger.records.info("Loaded \(results.count, privacy: .public) lab results")
        PHILogger.records.debug("Patient \(patientID, privacy: .private(mask: .hash))")
    }
}
