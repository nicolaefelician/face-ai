import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject private var globalState = GlobalState.shared
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.requestReview) var requestReview
    
    let termsOfUseUrl = "https://docs.google.com/document/d/1FrJuqu6jtwqWZ0mJiXe-cDIMotcfq7kHHmgUbmtKyGc/edit?usp=sharing"
    let privacyPolicyUrl = "https://docs.google.com/document/d/1SkhgKKJOPVVyZSfsDd66ENzVKLK68Jdq_MfE1-IQ9oI/edit?usp=sharing"
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        
        ScrollView {
            VStack(spacing: 20) {
                Button(action: { rateApp() }) {
                    SettingsButtonView(title: "Rate App", icon: "star.fill", iconColor: .yellow)
                }
                
                Button(action: { shareApp() }) {
                    SettingsButtonView(title: "Share App", icon: "square.and.arrow.up", iconColor: .blue)
                }
                
                Button(action: { contactUs() }) {
                    SettingsButtonView(title: "Contact us", icon: "ellipsis.message.fill", iconColor: .green)
                }
                
                Button(action: { openUrl(privacyPolicyUrl) }) {
                    SettingsButtonView(title: "Privacy Policy", icon: "lock.shield", iconColor: .purple)
                }
                
                Button(action: { openUrl(termsOfUseUrl) }) {
                    SettingsButtonView(title: "Terms of Use", icon: "doc.text", iconColor: .orange)
                }
                
                if !GlobalState.shared.isProUser {
                    Button(action: {
                        Task {
                            let result = await purchaseController.restorePurchases()
                            print("Restore result: \(result)")
                        }
                    }) {
                        SettingsButtonView(title: "Restore Purchases", icon: "arrow.clockwise", iconColor: .gray)
                    }
                }
            }
            .padding()
            .padding(.top, 15)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
        }
        .background(Color.white)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func restorePurchases() {
        Task {
            let result = await purchaseController.restorePurchases()
            switch result {
            case .restored:
                print("✅ Purchases restored")
            case .failed(let error):
                print("❌ Failed to restore purchases: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func contactUs() {
        let email = "esmondandersonhaldegallagher@gmail.com"
        let subject = "Support Request"
        let body = "Hi, I need help with... (Face AI 1.0.0)"
        let mailtoURL = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: mailtoURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Mail app is not available")
            }
        }
    }
    
    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func rateApp() {
        requestReview()
    }
    
    private func shareApp() {
        let url = "https://apps.apple.com/us/app/studio-ai-action-figure-trend/id6744292117"
        globalState.imagesToShow.append(url)
        globalState.isSharingImages = true
    }
}

struct SettingsButtonView: View {
    let title: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 17))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}
