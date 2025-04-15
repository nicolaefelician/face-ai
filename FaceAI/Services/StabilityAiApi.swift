import Foundation
import SwiftUI

final class StabilityAiApi {
    static let shared = StabilityAiApi()
    
    private init() {}
    
    func removeBackground(image: UIImage) async throws -> EnhanceJob {
        guard let userId = Consts.shared.userId else {
            throw ApiError.invalidResponse(message: "User ID not set")
        }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/stability/remove-background?userId=\(userId)") else {
            throw URLError(.badURL)
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw ApiError.invalidResponse(message: "Failed to convert image to JPEG")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await safeSession().data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("❌ Status:", httpResponse.statusCode)
            throw ApiError.invalidResponse(message: "Failed with status: \(httpResponse.statusCode)")
        }
        
        let decoded = try JSONDecoder().decode(EnhanceJob.self, from: data)
        
        DispatchQueue.main.async {
            GlobalState.shared.enhanceJobs.append(decoded)
        }
        
        return decoded
    }
}
