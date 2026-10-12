// SummitCare/Features/Records/RecordsView.swift (Solutions 18 and 20)
import SwiftUI

struct RecordsView: View {
    let model: RecordsModel
    let patientID: Patient.ID

    var body: some View {
        List {
            Section {
                Button("Request My Records") { Task { await model.requestExport(for: patientID) } }
                Button("Download PDF") { Task { await model.download(.pdf, for: patientID) } }
                Button("Download FHIR JSON") { Task { await model.download(.fhir, for: patientID) } }
            } footer: {
                if model.phase == .requested { Text("We'll notify you when your records are ready, within 30 days.") }
                if case .failed(let message) = model.phase { Text(message) }
            }
            if case .ready(let url) = model.phase {
                Section {
                    ShareLink(item: url) { Label("Save or Share", systemImage: "square.and.arrow.up") }
                    Button("Remove from This iPhone", role: .destructive) { model.removeLocalCopy() }
                } footer: {
                    Text("Once you save or share this file outside SummitCare, it's yours to protect. SummitCare can't secure copies in other apps.")
                }
            }
        }
        .navigationTitle("My Records")
    }
}

/// Builds RecordsModel from the environment for the Records tab.
struct RecordsScreen: View {
    @Environment(AppModel.self) private var model
    @State private var records: RecordsModel?

    var body: some View {
        Group {
            if let records, let patient = model.patient {
                RecordsView(model: records, patientID: patient.id)
            } else {
                ProgressView()
            }
        }
        .task { if records == nil { records = RecordsModel(api: model.apiClient) } }
    }
}
