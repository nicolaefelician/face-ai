import SwiftUI

struct SplashView: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                ProgressView()
                    .frame(width: 160, height: 250)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .task {
                do {
                    try await UserApi.shared.fetchUserJobs()
                    try await UserApi.shared.fetchEnhanceJobs()
                    try await UserApi.shared.fetchUserCredits()
                    
                    JobFetcher.shared.startWatcher()
                    
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    print("❌ Failed to fetch jobs: \(error)")
                }
                
                AnalyticsManager.shared.logEvent(name: "App Launched")

                withAnimation {
                    globalState.showSplashView = false
                }
            }
            
            VStack {
                Spacer()
                
                Text("Face AI")
                    .font(.custom(Fonts.shared.interSemibold, size: 28))
                    .foregroundStyle(.red.opacity(0.9))
                
                Text("Powered by Goat Apps")
                    .font(.custom(Fonts.shared.interRegular, size: 18))
                    .foregroundStyle(.black.opacity(0.65))
                    .padding(.bottom, 20)
                    .padding(.top, 1)
            }
        }
    }
}
