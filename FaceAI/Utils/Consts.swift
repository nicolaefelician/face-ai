import Foundation
import SwiftUI

final class Consts {
    static let shared = Consts()
    
    private init() {}
    
    let apiBaseUrl = "https://image-generation-backend-164860087792.us-central1.run.app"
    
    var selectedGender: String? = nil
    var userId: UUID? = nil
    var fcmTokenId: String? = nil
    
    var uploadedImages: [UIImage] = []
    
    var hasTunedModel: Bool = false
    
    let superwallApiKey = "pk_afd37508a38ea9ef7b9ac446f0d940e23138b3c0f8d8ba61"
    let revenueCatApiKey: String = "appl_XkYNHSHHWXphXOJgkAJvJiyuAyg"
    
    func loadConfig() {
        if let storedUserId = UserDefaults.standard.string(forKey: "userId"),
           let uuid = UUID(uuidString: storedUserId) {
            self.userId = uuid
        } else {
            let newUserId = UUID()
            self.userId = newUserId
            UserDefaults.standard.set(newUserId.uuidString, forKey: "userId")
        }
        
        selectedGender = UserDefaults.standard.string(forKey: "gender")
        fcmTokenId = UserDefaults.standard.string(forKey: "fcmToken")
        hasTunedModel = UserDefaults.standard.bool(forKey: "hasTunedModel")
        
        loadUploadedImages()
        loadSavedImages()
    }
    
    private func getUploadedImagesFileUrl() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("images.json")
    }
    
    private func loadUploadedImages() {
        let fileURL = getUploadedImagesFileUrl()
        
        do {
            let data = try Data(contentsOf: fileURL)
            let base64Strings = try JSONDecoder().decode([String].self, from: data)
            
            uploadedImages = base64Strings.compactMap { base64String -> UIImage? in
                guard let imageData = Data(base64Encoded: base64String) else { return nil }
                return UIImage(data: imageData)
            }
            
            print("✅ Images count: \(uploadedImages.count)")
        } catch {
            print("❌ Error loading images: \(error)")
        }
    }
    
    func requestPushPermissions() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Failed to request notifications: \(error)")
            } else {
                print("Push notification permission granted: \(granted)")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func saveImage(_ image: SavedImage) {
        let fileName = "saved_images.json"
        let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        var currentImages: [SavedImage] = GlobalState.shared.savedImages
        
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([SavedImage].self, from: data) {
            currentImages = decoded
        }
        
        if currentImages.contains(where: { $0.id == image.id }) {
            currentImages.removeAll { $0.id == image.id }
            GlobalState.shared.savedImages = currentImages
            return
        }
        
        currentImages.append(image)
        
        do {
            let jsonData = try JSONEncoder().encode(currentImages)
            try jsonData.write(to: fileURL, options: [.atomicWrite])
            GlobalState.shared.savedImages = currentImages
        } catch {
            print("❌ Failed to save image to cache:", error.localizedDescription)
        }
    }
    
    private func loadSavedImages() {
        let fileName = "saved_images.json"
        let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let savedImages = try JSONDecoder().decode([SavedImage].self, from: data)
            GlobalState.shared.savedImages = savedImages
            print("✅ Loaded \(savedImages.count) saved images from cache.")
        } catch {
            print("❌ Failed to load saved images from cache:", error.localizedDescription)
            GlobalState.shared.savedImages = []
        }
    }
    
    func setUploadImages(_ images: [UIImage]) {
        let encodedImages = images.compactMap { image in
            return image.toBase64()
        }
        
        do {
            let jsonData = try JSONEncoder().encode(encodedImages)
            let fileURL = getUploadedImagesFileUrl()
            try jsonData.write(to: fileURL, options: .atomic)
            
            uploadedImages = images
        } catch {
            print("❌ Error saving images: \(error)")
        }
    }
    
    func setGender(_ gender: String) {
        UserDefaults.standard.set(gender, forKey: "gender")
        self.selectedGender = gender
    }
    
    func setFcmToken(_ fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        self.fcmTokenId = fcmToken
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        GlobalState.shared.showOnboarding = false
    }
    
    func setHasTunedModel(_ value: Bool) {
        hasTunedModel = value
        UserDefaults.standard.set(value, forKey: "hasTunedModel")
    }
}
