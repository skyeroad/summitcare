// SummitCare/Features/Records/AmendmentRequestForm.swift (Solution 20)
import SwiftUI

struct AmendmentRequestForm: View {
    let draftTarget: AmendmentTarget
    let api: APIClient
    @Environment(\.dismiss) private var dismiss
    @State private var requestedChange = ""
    @State private var reason = ""
    @State private var isSubmitting = false
    @State private var failed = false

    var body: some View {
        Form {
            Section("What should be corrected?") { TextEditor(text: $requestedChange).frame(minHeight: 120) }
            Section("Why? (optional)") { TextEditor(text: $reason).frame(minHeight: 80) }
            Section {
                Button("Send Request") { Task { await send() } }
                    .disabled(isSubmitting || requestedChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } footer: { Text("Your care team will respond within 60 days. You'll see the decision here.") }
        }
        .navigationTitle("Request a Correction")
        .alert("We couldn't send your request.", isPresented: $failed) { Button("OK") {} }
    }

    private func send() async {
        isSubmitting = true
        defer { isSubmitting = false }
        let draft = AmendmentDraft(target: draftTarget, requestedChange: requestedChange, reason: reason)
        do {
            try await api.createAmendmentRequest(draft)
            dismiss()
        } catch {
            failed = true
        }
    }
}
