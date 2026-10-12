// SummitCare/Features/Messages/MessagesView.swift
import SwiftUI

struct MessagesView: View {
    @Environment(AppModel.self) private var model
    @State private var messages: [Message] = []
    @State private var composing = false

    var body: some View {
        List(messages) { message in
            VStack(alignment: .leading, spacing: 4) {
                Text(message.body)
                Text(message.createdAt, style: .relative).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Messages")
        .toolbar {
            Button("New Message", systemImage: "square.and.pencil") { composing = true }
                .disabled(model.patient == nil)
        }
        .sheet(isPresented: $composing) {
            if let patient = model.patient {
                NavigationStack { ComposeMessageView(patientID: patient.id) { await reload() } }
            }
        }
        .task(id: model.patient?.id) {
            await reload()
            await Analytics.shared.record(.messagesOpened)
        }
    }

    private func reload() async {
        guard let id = model.patient?.id else { return }
        do {
            messages = try await model.apiClient.send(Endpoints.messages(patientID: id), as: [Message].self)
        } catch {
            await model.handle(error)
        }
    }
}
