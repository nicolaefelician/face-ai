import Foundation

final class ImageJob: Identifiable, Decodable {
    let id: Int
    let userId: UUID
    let status: JobStatus
    let systemPrompt: String
    let creationDate: Date
    let images: String
    let presetCategory: PresetCategory
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case status
        case systemPrompt
        case creationDate
        case images
        case presetCategory
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        
        let statusRaw = try container.decode(Int.self, forKey: .status)
        self.status = JobStatus(rawValue: statusRaw) ?? .processing
        
        self.systemPrompt = try container.decode(String.self, forKey: .systemPrompt)
        self.images = try container.decode(String.self, forKey: .images)
        
        let presetRaw = try container.decode(String.self, forKey: .presetCategory)
        self.presetCategory = PresetCategory(rawValue: presetRaw) ?? .business
        
        let dateStr = try container.decode(String.self, forKey: .creationDate)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.creationDate = formatter.date(from: dateStr) ?? Date.now
    }
}
