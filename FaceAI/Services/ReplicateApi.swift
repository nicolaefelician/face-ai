import Foundation
import SwiftUI

final class ReplicateApi {
    static let shared = ReplicateApi()
    
    private init() {}
    
    func uploadImage(_ uiImage: UIImage) async throws -> String {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/replicate/upload-image") else {
            throw URLError(.badURL)
        }
        
        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            throw ApiError.invalidResponse(message: "Failed to convert UIImage to Data")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = "image.jpg"
        let mimeType = "image/jpeg"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "uploadImage", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        guard let imageUrl = result["imageUrl"] else {
            throw NSError(domain: "uploadImage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
        }
        
        return imageUrl
    }
    
    func createPrediction(imageUrl: String) async throws {
        guard let userId = Consts.shared.userId else { throw NSError(domain: "User ID not set", code: 0, userInfo: nil) }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/replicate/create-prediction?imageUrl=\(imageUrl)&userId=\(userId)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(EnhanceJob.self, from: data)
        
        DispatchQueue.main.async {
            GlobalState.shared.enhanceJobs.append(decoded)
            JobFetcher.shared.startWatcher()
        }
    }
}
