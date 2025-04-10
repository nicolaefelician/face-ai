import SwiftUI
import SuperwallKit

struct ContentView: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        ZStack {
            NavigationStack(path: $globalState.navigationPath) {
                HomeView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            VStack(spacing: 0) {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation {
                                        globalState.showMenu.toggle()
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 38, height: 38)
                                            .foregroundColor(.accent)
                                            .cornerRadius(7)
                                        
                                        if !globalState.showMenu {
                                            Image("menu")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 26, height: 26)
                                        } else {
                                            Image(systemName: "xmark")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .padding(.leading, 1)
                                }
                            }
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            VStack(spacing: 2) {
                                Text("Face AI")
                                    .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            VStack(spacing: 2) {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    Superwall.shared.register(placement: "campaign_trigger")
                                }) {
                                    Text(globalState.isProUser ? "\(globalState.credits)" : "Pro")
                                        .font(.custom(Fonts.shared.interSemibold, size: 14))
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 13)
                                        .background(Colors.shared.primaryColor)
                                        .cornerRadius(24)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            VStack(spacing: 2) {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    globalState.navigationPath.append(.settings)
                                }) {
                                    Image(systemName: "gearshape")
                                        .resizable()
                                        .scaledToFit()
                                        .fontWeight(.medium)
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    }
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .settings: SettingsView()
                        case .saved: SavedView()
                        case .history: HistoryView()
                        case .prompts(let category) : PromptsView(presetCategory: category)
                        case .imageFilter(let jobId, let type) : ImageFilterView(jobId: jobId, type: type)
                        }
                    }
                    .sheet(isPresented: $globalState.isSharingImages) {
                        ShareView(activityItems: globalState.imagesToShow)
                    }
                    .alert(isPresented: $globalState.showAlert) {
                        Alert(
                            title: Text(globalState.alertTitle ?? ""),
                            message: Text(globalState.alertMessage ?? ""),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        Color.clear.frame(height: 10)
                    }
                    .fullScreenCover(isPresented: $globalState.showFullscreenImage) {
                        FullscreenImageCover()
                    }
            }
            
            if globalState.showPresetPreview {
                ImagePresetPopup()
            } else if globalState.showImageFilter {
                ImageFilterPopup()
            } else if globalState.isLoading {
                ZStack {
                    Color.white
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .blur(radius: 10)
                        .background(.ultraThinMaterial)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .scaleEffect(1.6)
                        
                        Text("Processing your image...")
                            .font(.custom(Fonts.shared.interSemibold, size: 17))
                            .foregroundColor(.black.opacity(0.75))
                    }
                    .padding(30)
                    .cornerRadius(20)
                    .shadow(radius: 25)
                    .padding()
                }
                .transition(.opacity)
            } else if globalState.showQueuePopup {
                QueuePopup()
            }
        }
    }
}
