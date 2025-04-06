import Foundation

final class ImagePreset {
    let image: String
    let title: String?
    let systemPrompt: String
    let imageSize: CGSize
    let category: PresetCategory
    
    init(image: String, title: String? = nil, systemPrompt: String, imageSize: CGSize = CGSize(width: 115, height: 165), category: PresetCategory) {
        self.image = image
        self.title = title
        self.systemPrompt = systemPrompt
        self.imageSize = imageSize
        self.category = category
    }
}
