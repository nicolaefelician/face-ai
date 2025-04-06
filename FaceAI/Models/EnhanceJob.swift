import Foundation

final class EnhanceJob: Codable, Identifiable {
    let id: String
    let status: EnhanceStatus
    let createdAt: Date
    let userId: UUID
    let enhanceImages: [EnhanceImage]
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.status = try container.decode(EnhanceStatus.self, forKey: .status)
        let dateStr = try container.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.createdAt = formatter.date(from: dateStr) ?? Date.now
        self.enhanceImages = try container.decodeIfPresent([EnhanceImage].self, forKey: .enhanceImages) ?? []
        let stringUuid = try container.decode(String.self, forKey: .userId)
        self.userId = UUID(uuidString: stringUuid) ?? UUID()
    }
}
