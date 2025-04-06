import Foundation
import UIKit
import SwiftUI

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

enum PresetCategory: String, CaseIterable, Identifiable, Codable {
    case headshots = "Headshots"
    case business = "Business Suit"
    case cartoon = "Cartoon Avatar"
    case rapper = "Rapper Style"
    case surfing = "Surf Line"
    case gym = "Gym Mode"
    
    var id: String { self.rawValue }
}

enum ApiError: Error {
    case invalidResponse(message: String)
}

enum AuthorizationError: Error {
    case notAllowed
}

enum QueryError: Error {
    case phAssetNotFound
}

enum NavigationDestination: Hashable {
    case settings
//    case saved
    case history
    case prompts(category: PresetCategory?)
    case imageFilter(jobId: String, type: GenerationType)
}

enum JobStatus: Int, Codable {
    case processing = 0
    case complete = 1
}

enum EnhanceStatus: String, Codable {
    case starting = "Starting"
    case processing = "Processing"
    case successful = "Successful"
    case failed = "Failed"
    case canceled = "Canceled"
}

enum FilterType {
    case enhance
    case removeBackground
}

enum GenerationType: CaseIterable, Codable {
    case headshot
    case filter
}

final class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        withAnimation {
            if let error = error {
                GlobalState.shared.alertTitle = "Error"
                GlobalState.shared.alertMessage = error.localizedDescription
            } else {
                GlobalState.shared.alertTitle = "Success"
                GlobalState.shared.alertMessage = "Image was saved to your photo album!"
            }
            GlobalState.shared.showAlert = true
        }
    }
}

extension EnhanceStatus {
    var text: String {
        switch self {
        case .starting:
            return "Starting"
        case .processing:
            return "Processing"
        case .successful:
            return "Completed"
        case .failed:
            return "Failed"
        case .canceled:
            return "Canceled"
        }
    }
    
    var color: Color {
        switch self {
        case .starting: return .orange
        case .processing: return .blue
        case .successful: return .green
        case .failed: return .red
        case .canceled: return .gray
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

func imageFromBase64String(_ base64String: String) -> UIImage? {
    guard let imageData = Data(base64Encoded: base64String) else {
        print("❌ Invalid base64 string")
        return nil
    }
    
    return UIImage(data: imageData)
}
