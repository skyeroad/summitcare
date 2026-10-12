// SummitCare/Preview Content/PreviewData.swift (Solution 32)
#if DEBUG
import Foundation

enum PreviewData {
    // Avery Quinn, Jordan Ellis, Riley Navarro. Never real patients.
    static let patients: [Patient] = load("preview-patients")

    private static func load<T: Decodable>(_ name: String) -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Missing preview fixture \(name).json")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do { return try decoder.decode(T.self, from: data) }
        catch { fatalError("Invalid preview fixture \(name).json: \(error)") }
    }
}
#endif
