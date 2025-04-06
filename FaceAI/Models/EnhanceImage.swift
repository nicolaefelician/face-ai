import Foundation

final class EnhanceImage: Codable, Identifiable {
    let id: UUID
    let jobId: String
    let data: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.jobId = try container.decode(String.self, forKey: .jobId)
        self.data = try container.decode(String.self, forKey: .data)
    }
}
