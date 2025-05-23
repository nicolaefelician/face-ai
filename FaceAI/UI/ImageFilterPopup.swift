import SwiftUI
import SuperwallKit

struct ImageFilterPopup: View {
    @ObservedObject private var globalState = GlobalState.shared
    @ObservedObject private var photoService = PhotoLibraryService.shared
    
    @State private var isProcessing = false
    
    private func loadImageAsset() async {
        guard let assetLocalId = globalState.selectedImageId else {
            return
        }
        
        guard let uiImage = try? await photoService.fetchImage(
            byLocalIdentifier: assetLocalId,
            deliveryMode: .highQualityFormat
        ) else {
            return
        }
        globalState.selectedImage = uiImage
    }
    
    private func confirmAction() {
        guard let uiImage = globalState.selectedImage else { return }
        
        isProcessing = true
        
        Task {
            do {
                switch globalState.selectedFilterType {
                case .enhance:
                    withAnimation {
                        globalState.isLoading = true
                        globalState.showImageFilter = false
                    }
                    let imageUrl = try await ReplicateApi.shared.uploadImage(uiImage)
                    
                    try await ReplicateApi.shared.createPrediction(imageUrl: imageUrl)
                    
                    withAnimation {
                        globalState.showQueuePopup = true
                    }
                case .removeBackground:
                    let job = try await StabilityAiApi.shared.removeBackground(image: uiImage)
                    globalState.credits -= 5
                    globalState.navigationPath.append(.imageFilter(jobId: job.id, type: .filter))
                case .ghibli:
                    withAnimation {
                        globalState.isLoading = true
                        globalState.showImageFilter = false
                    }
                    let imageUrl = try await ReplicateApi.shared.uploadImage(uiImage)
                    
                    try await ReplicateApi.shared.createGhibliPrediction(imageUrl: imageUrl)
                    
                    withAnimation {
                        globalState.showQueuePopup = true
                    }
                }
            } catch {
                globalState.alertTitle = "Error"
                globalState.alertMessage = error.localizedDescription
                globalState.showAlert = true
            }
            
            withAnimation {
                globalState.isLoading = false
                globalState.showImageFilter = false
            }
            
            isProcessing = false
            globalState.selectedFilterType = .enhance
        }
    }
    
    private var descriptionText: String {
        switch globalState.selectedFilterType {
        case .enhance:
            return "Enhance this image to improve clarity and resolution. This action will cost 10 credits."
        case .removeBackground:
            return "Remove the background from this image. This action will cost 5 credits."
        case .ghibli:
            return "Apply a Ghibli-style effect to this image. This action will cost 10 credits."
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
                .blur(radius: 10)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        globalState.selectedFilterType = .enhance
                        globalState.showImageFilter = false
                    }
                }
                .task {
                    await loadImageAsset()
                }
                .onDisappear {
                    globalState.selectedImageId = nil
                }
            
            VStack(spacing: 20) {
                if let image = globalState.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 240, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal)
                }
                
                Text(descriptionText)
                    .font(.custom(Fonts.shared.interSemibold, size: 17))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isProcessing {
                    ProgressView("Processing...")
                } else {
                    HStack(spacing: 20) {
                        Button("Cancel") {
                            withAnimation {
                                globalState.selectedFilterType = .enhance
                                globalState.showImageFilter = false
                            }
                        }
                        .foregroundColor(.gray)
                        
                        Button("Apply") {
                            let filterType = globalState.selectedFilterType
                            
                            let isFirstTime = switch filterType {
                                case .enhance: !Consts.shared.hasUsedPhotoEnhancement
                                case .ghibli: !Consts.shared.hasUsedGhibliStyle
                                case .removeBackground: !Consts.shared.hasUsedBackgroundRemoval
                            }
                            
                            if isFirstTime {
                                switch filterType {
                                case .enhance: Consts.shared.setHasUsedPhotoEnhancer(true)
                                case .ghibli: Consts.shared.setHasUsedGhibliStyle(true)
                                case .removeBackground: Consts.shared.setHasUsedBackgroundRemover(true)
                                }
                                confirmAction()
                                return
                            }
                            
                            if globalState.credits < 1 {
                                Superwall.shared.register(placement: "campaign_trigger")
                                return
                            }
                            
                            confirmAction()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 30)
        }
    }
}
