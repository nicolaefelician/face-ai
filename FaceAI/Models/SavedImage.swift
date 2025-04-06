import Foundation

final class SavedImage: Codable {
    let jobId: String
    let index: Int
    let type: GenerationType
    let presetCategory: PresetCategory
    let creationDate: Date
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jobId = try container.decode(String.self, forKey: .jobId)
        self.index = try container.decode(Int.self, forKey: .index)
        self.type = try container.decode(GenerationType.self, forKey: .type)
        self.presetCategory = try container.decode(PresetCategory.self, forKey: .presetCategory)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
    }
    
    init(jobId: String, index: Int, type: GenerationType, presetCategory: PresetCategory, creationDate: Date) {
        self.jobId = jobId
        self.index = index
        self.type = type
        self.presetCategory = presetCategory
        self.creationDate = creationDate
    }
}

