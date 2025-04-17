import Foundation

final class EnhanceImage: Codable, Identifiable {
    let id: UUID
    let jobId: String
    let imageUrl: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stringId = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: stringId) ?? UUID()
        self.jobId = try container.decode(String.self, forKey: .jobId)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
}
