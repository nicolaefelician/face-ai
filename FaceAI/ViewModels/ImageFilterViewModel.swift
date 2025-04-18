import Foundation
import SwiftUI

final class ImageFilterViewModel: ObservableObject {
    @Published var selectedImageIndex = 0
    @Published var isLoading = false
    
    @Published var savedImagesIndex: [Int] = []
    
    @ObservedObject private var globalState = GlobalState.shared
    
    @Published var images: [UIImage] = []
    
    func loadImages(jobId: String, type: GenerationType) async {
        do {
            if type == .filter {
                let enhanceImages = try await UserApi.shared.getEnhanceJobImages(jobId: jobId)
                
                var loadedImages: [UIImage] = []
                
                for image in enhanceImages {
                    guard let url = URL(string: image.imageUrl) else { continue }
                    
                    let (data, _) = try await safeSession().data(from: url)
                    
                    if let image = UIImage(data: data) {
                        loadedImages.append(image)
                    }
                }
                
                DispatchQueue.main.async {
                    self.images = loadedImages
                }
                self.images = loadedImages
            } else {
                let urlStrings = try await UserApi.shared.getJobImages(jobId: jobId)
                
                var loadedImages: [UIImage] = []
                
                for urlString in urlStrings {
                    guard let url = URL(string: urlString) else { continue }
                    
                    let (data, _) = try await safeSession().data(from: url)
                    
                    if let image = UIImage(data: data) {
                        loadedImages.append(image)
                    }
                }
                
                DispatchQueue.main.async {
                    self.images = loadedImages
                }
            }
        } catch {
            globalState.alertTitle = "Error"
            globalState.alertMessage = "Failed to load images"
            globalState.showAlert = true
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func addToSaved() {
        if let imageData = images[selectedImageIndex].pngData() {
            let savedImage = SavedImage(id: UUID(), imageData: imageData, creationDate: Date.now)
            Consts.shared.saveImage(savedImage)
            savedImagesIndex.append(selectedImageIndex)
        }
    }
}
