import SwiftUI

struct ImageFilterView: View {
    let jobId: String
    let type: GenerationType
    
    @StateObject private var viewModel = ImageFilterViewModel()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var globalState = GlobalState.shared
    
    private func saveToPhotos(_ image: UIImage) {
        let saver = ImageSaver()
        saver.writeToPhotoAlbum(image: image)
    }
    
    var body: some View {
        VStack {
            if viewModel.images.isEmpty {
                Spacer()
                ProgressView("Loading images...")
                    .padding(.top, 100)
                Spacer()
            } else {
                GeometryReader { geometry in
                    TabView(selection: $viewModel.selectedImageIndex) {
                        ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, image in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                globalState.selectedImage = image
                                globalState.showFullscreenImage = true
                            }) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: geometry.size.width * 0.8,
                                        height: geometry.size.height * 0.8
                                    )
                                    .clipped()
                                    .cornerRadius(22)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: min(geometry.size.height * 0.8, 550))
                    .padding(.vertical, 20)
                }
                
                if viewModel.images.count > 1 {
                    HStack {
                        ForEach(viewModel.images.indices, id: \.self) { index in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.selectedImageIndex = index
                            }) {
                                Rectangle()
                                    .frame(height: 4)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(viewModel.selectedImageIndex == index ? Colors.shared.primaryColor : .gray.opacity(0.4))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 70)
                    .padding(.bottom, 40)
                }
            }
            
            Spacer()
            
            if !viewModel.images.isEmpty {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if viewModel.images.count <= 1 {
                            presentationMode.wrappedValue.dismiss()
                        } else if viewModel.selectedImageIndex < viewModel.images.count {
                            withAnimation {
                                viewModel.images.remove(at: viewModel.selectedImageIndex)
                            }
                        }
                    }) {
                        Image("delete")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(15)
                            .background(
                                Circle()
                                    .stroke(Color.red, lineWidth: 1.5)
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        
                        saveToPhotos(viewModel.images[viewModel.selectedImageIndex])
                    }) {
                        Image("download")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(15)
                            .background(
                                Circle()
                                    .stroke(Color(hex: "#808080"), lineWidth: 1.5)
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        globalState.imagesToShow = [viewModel.images[viewModel.selectedImageIndex]]
                        globalState.isSharingImages = true
                    }) {
                        Image("share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(15)
                            .background(
                                Circle()
                                    .stroke(Color(hex: "#808080"), lineWidth: 1.5)
                            )
                    }
                    
                    Spacer()
                    
                    if viewModel.selectedImageIndex < viewModel.images.count {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            if viewModel.savedImagesIndex.contains(where: { $0 == viewModel.selectedImageIndex }) {
                                return
                            }
                            
                            viewModel.addToSaved()
                        }) {
                            let isSaved = viewModel.savedImagesIndex.contains(viewModel.selectedImageIndex)
                            
                            Image(isSaved ? "saved" : "save")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .padding(15)
                                .background(
                                    Circle()
                                        .stroke(Color(hex: "#808080"), lineWidth: 1.5)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 25)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Results")
                    .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let email = "esmondandersonhaldegallagher@gmail.com"
                    let subject = "Support Request"
                    let body = "Hi, I need help with... (Face AI 1.0.0)"
                    let mailtoURL = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                    
                    if let url = URL(string: mailtoURL), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("Report issue")
                            .foregroundColor(Color(hex: "#808080"))
                            .font(.custom(Fonts.shared.interRegular, size: 13))
                        
                        Image("info")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
        .task {
            await viewModel.loadImages(jobId: jobId, type: type)
        }
    }
}
