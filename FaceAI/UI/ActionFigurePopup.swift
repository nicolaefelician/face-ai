import SwiftUI
import SuperwallKit

struct ActionFigurePopup: View {
    @ObservedObject private var globalState = GlobalState.shared
    @State private var promptText: String = ""
    
    let systemPrompt = """
    Create a clean, front-facing action figure blister pack of a sks male, preserving distinct facial features, hairstyle, and casual sporty outfit. The figure is posed upright and centered inside the packaging, with a confident expression.
    The packaging is titled **"Agent AI"** in bold, futuristic font at the top. Accessories are arranged neatly to the side: a laptop, terminal window, AI chip, command-line coffee mug, wireless headphones, and a floating robot assistant.
    Use a symmetrical, toy packaging style with smooth plastic casing and a matte cardboard background. Lighting should be soft and neutral. Avoid angled perspectives — make it look like a real-life boxed action figure, viewed directly from the front.
    """
    
    private func combinedPrompt(with userInput: String) -> String {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedInput.isEmpty else {
            return systemPrompt
        }

        return """
        \(systemPrompt)

        Additional customization requested by the user:
        \(trimmedInput)
        """
    }
    
    private func onConfirm() async {
        do {
            withAnimation {
                globalState.showPresetPreview = false
                globalState.isLoading = true
            }
            
            let imagePreset = ImagePreset(image: "", title: nil, systemPrompt: combinedPrompt(with: promptText), category: .headshots)
            
            if !Consts.shared.hasTunedModel {
                try await ImageAiApi.shared.tuneModel(preset: imagePreset)
            } else {
                try await ImageAiApi.shared.createGenerationQueue(preset: imagePreset)
            }
            
            withAnimation {
                globalState.showQueuePopup = true
            }
        } catch {
            globalState.alertTitle = "Error"
            globalState.alertMessage = error.localizedDescription
            globalState.showAlert = true
        }
        
        withAnimation {
            globalState.isLoading = false
        }
    }
    
    var body: some View {
        if let image = globalState.selectedImage {
            ZStack {
                Color.white.opacity(0.9)
                    .blur(radius: 10)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            globalState.showActionFigurePopup = false
                        }
                    }
                
                VStack(spacing: 12) {
                    Spacer()
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(radius: 10)
                    
                    Text("Create Your Action Figure")
                        .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                        .padding(.top, 10)
                    
                    Text("Turn yourself into a collectible action figure! Add custom details like outfit, accessories, or theme. This will cost 15 credits.")
                        .font(.custom(Fonts.shared.interRegular, size: 17))
                        .foregroundStyle(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, isIpad ? 90 : 28)
                        .padding(.top)
                    
                    TextField("Describe your action figure (e.g., cyber ninja with glowing sword)...", text: $promptText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .font(.custom(Fonts.shared.interRegular, size: 16))
                        .padding(.horizontal, isIpad ? 90 : 24)
                    
                    Button(action: {
                        Task {
                            if globalState.credits < 1 {
                                Superwall.shared.register(placement: "campaign_trigger")
                                return
                            }
                            await onConfirm()
                        }
                    }) {
                        Text("Generate Action Figure")
                            .font(.custom(Fonts.shared.instrumentSansSemibold, size: 19))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Colors.shared.primaryColor)
                            .cornerRadius(12)
                            .padding(.horizontal, isIpad ? 90 : 24)
                    }
                    
                    Button(action: {
                        withAnimation {
                            globalState.showActionFigurePopup = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Back")
                                .font(.custom(Fonts.shared.interSemibold, size: 17))
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 5)
                        .padding(.top)
                    }
                    
                    Spacer()
                }
            }
            .animation(.easeInOut, value: globalState.showPresetPreview)
        }
    }
}
