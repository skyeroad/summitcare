// SummitCareNotificationService/PreviewFetcher.swift (Solution 24)
import Foundation

struct MessagePreview: Decodable, Sendable {
    let title: String
    let body: String
}

enum PreviewFetcher {
    static func fetch(messageID: String, token: String) async throws -> MessagePreview {
        guard !messageID.isEmpty, messageID.allSatisfy(\.isNumber),
              let url = URL(string: "https://api.summitcare.example/api/v1/notification_previews/\(messageID)")
        else { throw URLError(.badURL) }
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(MessagePreview.self, from: data)
    }
}
