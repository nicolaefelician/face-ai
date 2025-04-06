import Foundation
import SwiftUI

final class JobFetcher {
    static let shared = JobFetcher()
    
    private var isRunning = false
    @ObservedObject private var globalState = GlobalState.shared
    
    private init() {}
    
    func startWatcher() {
        guard !isRunning else { return }
        isRunning = true
        
        Task {
            while isRunning {
                do {
                    var shouldContinue = false
                    
                    if globalState.historyJobs.contains(where: { $0.status == .processing }) {
                        try await UserApi.shared.fetchUserJobs()
                        shouldContinue = true
                    }
                    
                    if globalState.enhanceJobs.contains(where: { $0.status == .processing }) {
                        try await UserApi.shared.fetchEnhanceJobs()
                        shouldContinue = true
                    }
                    
                    if !shouldContinue {
                        isRunning = false
                        break
                    }
                } catch {
                    print("❌ Failed to fetch jobs: \(error.localizedDescription)")
                }
                
                try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            }
        }
    }
    
    func stopWatcher() {
        isRunning = false
    }
}
