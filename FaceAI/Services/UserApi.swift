import Foundation

final class UserApi {
    static let shared = UserApi()
    
    private init() {}
    
    private struct CreditResponse: Decodable {
        let credits: Int
    }
    
    @MainActor
    func fetchUserCredits() async throws {
        guard let userId = Consts.shared.userId else {
            throw ApiError.invalidResponse(message: "User ID not found")
        }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/user/get-credits?userId=\(userId.uuidString)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await safeSession().data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ApiError.invalidResponse(message: "Failed to fetch credits")
        }
        
        let decoded = try JSONDecoder().decode(CreditResponse.self, from: data)
        
        DispatchQueue.main.async {
            GlobalState.shared.credits = decoded.credits
        }
    }
    
    func registerUser() async throws {
        guard let gender = Consts.shared.selectedGender else {
            throw ApiError.invalidResponse(message: "User gender not selected")
        }
        
        guard let userId = Consts.shared.userId else {
            throw ApiError.invalidResponse(message: "User ID not found")
        }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/user/register-user") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any?] = [
            "tuneId": 0,
            "gender": gender,
            "fcmTokenId": Consts.shared.fcmTokenId,
            "id": userId.uuidString
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        let (_, response) = try await safeSession().data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ApiError.invalidResponse(message: "The server returned an error code: \(httpResponse.statusCode)")
        }
        
        print("✅ User registered successfully")
    }
    
    func getJobImages(jobId: String) async throws -> [String] {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/job/list-job-images?jobId=\(jobId)") else { throw URLError(.badURL) }
        
        let (data, _) = try await safeSession().data(from: url)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        
        return decoded
    }
    
    func fetchUserJobs() async throws {
        guard let userId = Consts.shared.userId else {
            print("⚠️ No user ID found. Skipping fetching jobs.")
            return
        }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/job/list?userId=\(userId)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await safeSession().data(for: request)
        let decoded = try JSONDecoder().decode([ImageJob].self, from: data)
        
        DispatchQueue.main.async {
            GlobalState.shared.historyJobs = decoded
        }
    }
    
    func getEnhanceJobImages(jobId: String) async throws -> [EnhanceImage] {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/job/list-enhance-job-images?jobId=\(jobId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await safeSession().data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("Failed to fetch enhance images. Status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode([EnhanceImage].self, from: data)
        
        return decoded
    }
    
    func fetchEnhanceJobs() async throws {
        guard let userId = Consts.shared.userId else {
            print("⚠️ No user ID found. Skipping fetching jobs.")
            return
        }
        
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/job/list-enhance-jobs?userId=\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await safeSession().data(for: request)
        
        let decoded = try JSONDecoder().decode([EnhanceJob].self, from: data)
        
        DispatchQueue.main.async {
            GlobalState.shared.enhanceJobs = decoded
        }
    }
}
