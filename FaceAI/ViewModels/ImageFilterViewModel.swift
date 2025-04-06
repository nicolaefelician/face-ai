import Foundation
import SwiftUI

final class ImageFilterViewModel: ObservableObject {
    @Published var selectedImageIndex = 0
    @Published var isLoading = false
    
    @ObservedObject private var globalState = GlobalState.shared
    
    @Published var images: [UIImage] = []
    
    func loadImages(jobId: String, type: GenerationType) async {
        do {
            if type == .filter {
                let enhanceImages = try await UserApi.shared.getEnhanceJobImages(jobId: jobId)
                let loadedImages = enhanceImages.compactMap { imageFromBase64String($0.data) }
                
                DispatchQueue.main.async {
                    self.images = loadedImages
                }
            } else {
                let urlStrings = try await UserApi.shared.getJobImages(jobId: jobId)
                
                var loadedImages: [UIImage] = []
                
                for urlString in urlStrings {
                    guard let url = URL(string: urlString) else { continue }
                    
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
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
    
    func addToSaved(image: UIImage) {
        
    }
}
