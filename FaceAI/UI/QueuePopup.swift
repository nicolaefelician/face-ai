import SwiftUI

struct QueuePopup: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Your image is processing")
                    .font(.custom(Fonts.shared.instrumentSansSemibold, size: 21))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("You’ll get a notification once\nit’s ready.")
                    .font(.custom(Fonts.shared.interRegular, size: 16))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                
                ProgressView()
                
                Button(action: {
                    withAnimation {
                        globalState.showQueuePopup = false
                    }
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 25)
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
    }
}
