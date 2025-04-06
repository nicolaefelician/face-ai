import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject private var globalState = GlobalState.shared
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.requestReview) var requestReview
    
    let termsOfUseUrl = "https://docs.google.com/document/d/1FrJuqu6jtwqWZ0mJiXe-cDIMotcfq7kHHmgUbmtKyGc/edit?usp=sharing"
    let privacyPolicyUrl = "https://docs.google.com/document/d/1SkhgKKJOPVVyZSfsDd66ENzVKLK68Jdq_MfE1-IQ9oI/edit?usp=sharing"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button(action: { rateApp() }) {
                    SettingsButtonView(title: "Rate App", icon: "star.fill")
                }
                
                Button(action: { shareApp() }) {
                    SettingsButtonView(title: "Share App", icon: "square.and.arrow.up")
                }
                
                Button(action: { contactUs() }) {
                    SettingsButtonView(title: "Contact us", icon: "ellipsis.message.fill")
                }
                
                Button(action: { openUrl(privacyPolicyUrl) }) {
                    SettingsButtonView(title: "Privacy Policy", icon: "lock.shield")
                }
                
                Button(action: { openUrl(termsOfUseUrl) }) {
                    SettingsButtonView(title: "Terms of Use", icon: "doc.text")
                }
            }
            .padding()
            .padding(.top, 15)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
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
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)
            
            Text(title)
                .foregroundColor(.gray)
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 17))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}
