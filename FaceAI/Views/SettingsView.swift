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
            .padding(.horizontal, screenWidth * 0.02)
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
        let url = ""
        globalState.imagesToShow.append(url)
        globalState.isSharingImages = true
    }
}

struct SettingsButtonView: View {
    let title: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .foregroundColor(iconColor)
            
            Text(title)
                .foregroundColor(.black)
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 17))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
