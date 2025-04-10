import SwiftUI
import SuperwallKit

struct ImagePresetPopup: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    private func onConfirm(_ preset: ImagePreset) async {
        do {
            withAnimation {
                globalState.showPresetPreview = false
                globalState.isLoading = true
            }
            
            if !Consts.shared.hasTunedModel {
                try await ImageAiApi.shared.tuneModel(preset: preset)
                globalState.historyJobs.append(ImageJob())
                
            } else {
                try await ImageAiApi.shared.createGenerationQueue(preset: preset)
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
        if let preset = globalState.selectedPreset {
            ZStack {
                Color.white.opacity(0.9)
                    .blur(radius: 10)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            globalState.showPresetPreview = false
                        }
                    }
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    AsyncImage(url: URL(string: preset.image)!) { phase in
                        if phase.error != nil {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 380)
                        } else if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 380)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(radius: 10)
                        } else {
                            ProgressView()
                                .frame(height: 380)
                        }
                    }
                    
                    if let title = preset.title {
                        Text(title)
                            .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                            .padding(.top, 10)
                    }
                    
                    Text("We'll use the style and composition of this preset to generate photos of yourself")
                        .font(.custom(Fonts.shared.interRegular, size: 17))
                        .foregroundStyle(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top)
                    
                    Button(action: {
                        Task {
                            if globalState.credits < 1 {
                                Superwall.shared.register(placement: "campaign_trigger")
                                return
                            }
                            
                            await onConfirm(preset)
                        }
                    }) {
                        Text("Use This Preset")
                            .font(.custom(Fonts.shared.instrumentSansSemibold, size: 19))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Colors.shared.primaryColor)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                    }
                    
                    Button(action: {
                        withAnimation {
                            globalState.showPresetPreview = false
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
