// SummitCare/Features/Messages/ComposeMessageView.swift (Solution 12)
import SwiftUI

struct ComposeMessageView: View {
    let patientID: Patient.ID
    let onSent: () async -> Void
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var failed = false

    var body: some View {
        Form {
            // No autocorrection: the keyboard's learned-word cache would keep PHI.
            TextField("Message", text: $draft, axis: .vertical)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
        }
        .navigationTitle("New Message")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Send") { Task { await send() } }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .alert("We couldn't send your message.", isPresented: $failed) { Button("OK") {} }
    }

    private func send() async {
        do {
            _ = try await model.apiClient.send(try Endpoints.sendMessage(patientID: patientID, body: draft),
                                               as: Message.self)
            await Analytics.shared.record(.messageSent)
            await onSent()
            dismiss()
        } catch {
            failed = true
            await model.handle(error)
        }
    }
}
