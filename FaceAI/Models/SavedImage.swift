import Foundation

final class SavedImage: Codable {
    let id: UUID
    let imageData: Data
    let creationDate: Date
    
    init(id: UUID, imageData: Data, creationDate: Date) {
        self.id = id
        self.imageData = imageData
        self.creationDate = creationDate
    }
}
