import SwiftUI

final class ImageAiApi {
    static let shared = ImageAiApi()
    
    private init() {}
    
    private struct ImageGenerationResponse: Codable {
        struct PromptResponse: Codable {
            let images: [String]
        }
        
        let prompt: PromptResponse
    }
    
    private func createMultipartBody(
        images: [UIImage],
        boundary: String,
        gender: String,
        prompt: String,
        presetCategory: String
    ) -> Data {
        var body = Data()
        
        let params: [String: String] = [
            "gender": gender,
            "prompt": prompt,
            "presetCategory": presetCategory
        ]
        
        for (key, value) in params {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.9) else { continue }
            
            let filename = "image\(index).jpg"
            let mimetype = "image/jpeg"
            let fieldName = "images"
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    func tuneModel(preset: ImagePreset) async throws {
        if Consts.shared.uploadedImages.isEmpty {
            throw ApiError.invalidResponse(message: "No images uploaded")
        }
        
        guard let gender = Consts.shared.selectedGender else {
            throw ApiError.invalidResponse(message: "User gender must be selected")
        }
        
        guard let userId = Consts.shared.userId else {
            throw ApiError.invalidResponse(message: "User id must be set")
        }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/image/tune-model?userId=\(userId)") else {
            throw ApiError.invalidResponse(message: "Url is invalid")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(images: Consts.shared.uploadedImages, boundary: boundary, gender: gender, prompt: preset.systemPrompt, presetCategory: preset.category.rawValue)
        
        request.httpBody = httpBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let stringData = String(data: data, encoding: .utf8) {
            print("Response body: \(stringData)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw ApiError.invalidResponse(message: "Invalid status code: \(httpResponse.statusCode)")
            }
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response body: \(responseString)")
        }
        
        Consts.shared.setHasTunedModel(true)
    }
    
    func createGenerationQueue(preset: ImagePreset) async throws {
        guard let userId = Consts.shared.userId else {
            throw ApiError.invalidResponse(message: "User ID is required")
        }
        
        let encodedPrompt = preset.systemPrompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/image/generate-headshot?userId=\(userId)&prompt=\(encodedPrompt)&presetCategory=\(preset.category.rawValue)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON string: \(jsonString)")
        }
        
        let job = try JSONDecoder().decode(ImageJob.self, from: data)
        
        DispatchQueue.main.async {
            GlobalState.shared.historyJobs.append(job)
            JobFetcher.shared.startWatcher()
        }
    }
}
