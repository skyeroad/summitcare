// SummitCare/Features/LabResults/LabResultsView.swift
import SwiftUI

struct LabResultsView: View {
    @Environment(AppModel.self) private var model
    @State private var labResults = LabResultsModel()

    var body: some View {
        List(labResults.results) { result in
            NavigationLink(value: result) {
                VStack(alignment: .leading) {
                    Text(result.testName ?? "Lab result").font(.headline)
                    Text(result.resultedAt, style: .date).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Lab Results")
        .navigationDestination(for: LabResult.self) { LabResultDetailView(labResult: $0) }
        .overlay { if labResults.failed { ContentUnavailableView("Couldn't load results", systemImage: "wifi.slash") } }
        .task(id: model.patient?.id) {
            guard let id = model.patient?.id else { return }
            await labResults.load(patientID: id, using: model)
            await Analytics.shared.record(.labResultsOpened)
        }
    }
}

struct LabResultDetailView: View {
    let labResult: LabResult
    @Environment(AppModel.self) private var model

    var body: some View {
        Form {
            LabeledContent("Test", value: labResult.testName ?? "")
            LabeledContent("Result", value: [labResult.value, labResult.unit].compactMap(\.self).joined(separator: " "))
            if let range = labResult.referenceRange { LabeledContent("Reference range", value: range) }
            LabeledContent("Resulted", value: labResult.resultedAt.formatted(date: .abbreviated, time: .shortened))
            if let notes = labResult.notes { Section("Notes") { Text(notes) } }
            Section {
                Button("Copy Result") {
                    SensitivePasteboard.copy("\(labResult.testName ?? ""): \(labResult.value ?? "") \(labResult.unit ?? "")")
                }
            } footer: { Text("Copied results stay on this iPhone and clear after a minute.") }
            Section {
                NavigationLink("Request a Correction") {
                    AmendmentRequestForm(
                        draftTarget: AmendmentTarget(type: "LabResult", id: labResult.id, patientID: labResult.patientID),
                        api: model.apiClient)
                }
            }
        }
        .navigationTitle(labResult.testName ?? "Lab Result")
        .userActivity(LabResultActivity.type) { LabResultActivity.configure($0, labResultID: labResult.id) }
    }
}
