import SwiftUI

struct FullscreenImageCover: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    @State private var zoomScale: CGFloat = 1
    private let minZoomScale: CGFloat = 1
    private let maxZoomScale: CGFloat = 5
    @State private var previousZoomScale : CGFloat = 1
    
    @State private var image: Image?
    
    private func onImageDoubleTapped() {
        withAnimation(.spring()) {
            zoomScale = zoomScale == minZoomScale ? maxZoomScale : minZoomScale
        }
    }
    
    private func onZoomGestureStarted(value: MagnificationGesture.Value) {
        withAnimation(.easeIn(duration: 0.05)) {
            let delta = value / previousZoomScale
            previousZoomScale = value
            let zoomDelta = zoomScale * delta
            var minMaxScale = max(minZoomScale, zoomDelta)
            minMaxScale = min(maxZoomScale, minMaxScale)
            zoomScale = minMaxScale
        }
    }
    
    private func onZoomGestureEnded(value: CGFloat) {
        withAnimation(.easeIn(duration: 1)) {
            previousZoomScale = 1
            zoomScale = minZoomScale
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if let image = image {
                GeometryReader { proxy in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(zoomScale)
                        .gesture(
                            TapGesture(count: 2).onEnded {
                                onImageDoubleTapped()
                            }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged(onZoomGestureStarted)
                                .onEnded(onZoomGestureEnded)
                        )
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .animation(.easeInOut(duration: 0.33), value: zoomScale)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            globalState.showFullscreenImage = false
                            globalState.selectedImageUrl = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            if let uiImage = globalState.selectedImage {
                image = Image(uiImage: uiImage)
            }
        }
    }
}
