import SwiftUI
import Lottie
import SuperwallKit

struct SplashView: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    @ObservedObject private var photoLibraryService = PhotoLibraryService.shared
    
    private func requestForAuthorizationIfNecessary() {
        guard photoLibraryService.authorizationStatus != .authorized ||
                photoLibraryService.authorizationStatus != .limited
        else { return }
        
        photoLibraryService.requestAuthorization { error in
            guard error != nil else { return }
            self.globalState.alertTitle = "Error"
            self.globalState.alertMessage = "Failed to authorize access to Photos."
            self.globalState.showAlert = true
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                LottieView(animation: .named("generating"))
                    .looping()
                    .resizable()
                    .scaledToFit()
                    .frame(width: isIpad ? 250 : 200, height: isIpad ? 250 : 200)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .task {
                do {
                    JobFetcher.shared.startWatcher()
                    
                    if !globalState.showOnboarding {
                        requestForAuthorizationIfNecessary()
                        
                        if !globalState.isProUser {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            Superwall.shared.register(placement: "campaign_trigger")
                        }
                    }
                } catch {
                    print("❌ Failed to fetch jobs: \(error)")
                }
                
                AnalyticsManager.shared.logEvent(name: "App Launched")
                
                withAnimation {
                    globalState.showSplashView = false
                }
            }
            
            VStack(spacing: 10) {
                Spacer()
                
                Text("Toon AI")
                    .font(.custom(Fonts.shared.instrumentSansSemibold, size: 28))
                    .foregroundStyle(.red.opacity(0.9))
                
                Text("Powered by Denice Apps")
                    .font(.custom(Fonts.shared.interRegular, size: 18))
                    .foregroundStyle(.black.opacity(0.65))
                    .padding(.bottom, 20)
                    .padding(.top, 1)
            }
        }
    }
}
