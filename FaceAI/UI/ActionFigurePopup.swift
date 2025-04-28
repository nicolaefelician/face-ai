import SwiftUI
import SuperwallKit

struct ActionFigurePopup: View {
    @ObservedObject private var globalState = GlobalState.shared
    @State private var nameText: String = ""
    @State private var promptText: String = ""
    @State private var selectedAccessories: [String] = []
    
    private let accessories = [
        "Laptop",
        "Coffee Cup",
        "Glasses",
        "Backpack",
        "Sneakers",
        "Headphones",
        "Book",
        "Smartphone",
        "Watch",
        "Notebook",
        "Pen",
        "Headset",
        "Hat",
        "Keychain",
        "Charger",
        "Camera",
        "Water Bottle"
    ]
    
    let systemPrompt = """
    Create a clean, front-facing sks \(Consts.shared.selectedGender ?? "") action figure blister pack of a realistic human character. Preserve distinct facial features, hairstyle, and clothing style. 
    The figure should be posed upright and centered inside the packaging with a natural, confident expression.
    
    Leave space at the top for a bold title (user-specified). Accessories should be arranged neatly to the side — based on the user's description. 
    The packaging style should be symmetrical and realistic, with smooth plastic casing and a matte cardboard background.
    
    Lighting should be soft and neutral. Avoid angled perspectives — the view should look like a real-life boxed action figure photographed directly from the front.
    """
    
    private func combinedPrompt() -> String {
        var combined = systemPrompt
        
        if !nameText.trimmingCharacters(in: .whitespaces).isEmpty {
            combined += "\n\nAction figure name: \(nameText)"
        }
        
        if !promptText.trimmingCharacters(in: .whitespaces).isEmpty {
            combined += "\n\nUser description: \(promptText)"
        }
        
        if !selectedAccessories.isEmpty {
            combined += "\n\nAccessories to include: \(selectedAccessories.joined(separator: ", "))"
        }
        
        return combined
    }
    
    private func onConfirm() async {
        do {
            withAnimation {
                globalState.showActionFigurePopup = false
                globalState.isLoading = true
            }
            
            let imagePreset = ImagePreset(image: "", title: nil, systemPrompt: combinedPrompt(), category: .headshots)
            
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
    
    private var isFormValid: Bool {
        !nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
                .blur(radius: 10)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        globalState.showActionFigurePopup = false
                    }
                }
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("Create Your Action Figure")
                    .font(.custom(Fonts.shared.instrumentSansSemibold, size: 24))
                    .padding(.top, 10)
                
                Text("Add a name and customize your action figure with accessories! This will cost 15 credits.")
                    .font(.custom(Fonts.shared.interRegular, size: 17))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, isIpad ? 90 : 28)
                
                VStack(spacing: 10) {
                    TextField("Action Figure Name...", text: $nameText)
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .font(.custom(Fonts.shared.interRegular, size: 16))
                        .padding(.horizontal, isIpad ? 90 : 24)
                    
                    TextField("Describe your action figure (e.g., cyber ninja with glowing sword)...", text: $promptText)
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .font(.custom(Fonts.shared.interRegular, size: 16))
                        .padding(.horizontal, isIpad ? 90 : 24)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(accessories, id: \.self) { accessory in
                            Button(action: {
                                if selectedAccessories.contains(accessory) {
                                    selectedAccessories.removeAll { $0 == accessory }
                                } else {
                                    selectedAccessories.append(accessory)
                                }
                            }) {
                                Text(accessory)
                                    .font(.custom(Fonts.shared.interSemibold, size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedAccessories.contains(accessory) ? Colors.shared.primaryColor : Color(.systemGray5))
                                    .foregroundColor(selectedAccessories.contains(accessory) ? .white : .black)
                                    .clipShape(Capsule())
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal, isIpad ? 90 : 24)
                }
                .padding(.top, 8)
                
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
                        .background(isFormValid ? Colors.shared.primaryColor : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal, isIpad ? 90 : 24)
                }
                .disabled(!isFormValid)
                
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
        .animation(.easeInOut, value: selectedAccessories)
    }
}
