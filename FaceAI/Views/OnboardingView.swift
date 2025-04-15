import SwiftUI
import PhotosUI
import SuperwallKit
import Lottie

struct OnboardingView: View {
    private struct OnboardingInfo {
        let firstTitle: String
        let secondTitle: String
        let description: String
        let image: String
        let topPadding: CGFloat
        let imageWidth: CGFloat
        let imagePadding: CGFloat
        let shadowHeight: CGFloat
        
        init(firstTitle: String, secondTitle: String, description: String, image: String, topPadding: CGFloat, imageWidth: CGFloat, imagePadding: CGFloat, shadowHeight: CGFloat) {
            self.firstTitle = firstTitle
            self.secondTitle = secondTitle
            self.description = description
            self.image = image
            self.topPadding = topPadding
            self.imageWidth = imageWidth
            self.imagePadding = imagePadding
            self.shadowHeight = shadowHeight
        }
    }
    
    @StateObject private var viewModel = OnboardingViewModel()
    @ObservedObject private var globalState = GlobalState.shared
    
    private func genderPickerPage() -> some View {
        let screenWidth = UIScreen.main.bounds.width

        return VStack {
            Image("gender")
                .resizable()
                .scaledToFit()
                .frame(width: isIpad ? 400 : 240, height: isIpad ? 400 : 240)
                .padding(.top, isIpad ? 150 : 65)
            
            Text("Select Gender")
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 28))
                .foregroundStyle(.black)
                .padding(.top, 30)
            
            Text("Please select your gender")
                .font(.custom(Fonts.shared.interRegular, size: 17))
                .foregroundStyle(.black.opacity(0.7))
            
            HStack(spacing: 20) {
                ForEach(["Male", "Female"], id: \.self) { gender in
                    let isSelected = viewModel.selectedGender == gender.lowercased()
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.selectedGender = gender.lowercased()
                    }) {
                        VStack {
                            Image(gender.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text(gender)
                                .font(.custom(Fonts.shared.interSemibold, size: 19))
                                .foregroundStyle(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Colors.shared.primaryColor : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
            .padding()
            .padding(.top)
            .padding(.horizontal, screenWidth * 0.04)
            
            Spacer()
            
            Button(action: {
                if viewModel.selectedGender.isEmpty { return }
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                Consts.shared.setGender(viewModel.selectedGender)
                withAnimation {
                    viewModel.showGenderPicker = false
                    viewModel.showFaceProcessing = true
                }
            }) {
                ZStack(alignment: .center) {
                    Text("Continue")
                        .font(.custom(Fonts.shared.interSemibold, size: isIpad ? 24 : 20))
                        .foregroundStyle(Color.white)
                        .padding(.vertical, isIpad ? 22 : 16)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.selectedGender.isEmpty ? Color.gray : Colors.shared.primaryColor)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                    
                    HStack {
                        Spacer()
                        
                        Image("arrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 21, height: 21)
                            .padding(.trailing, 15)
                    }
                }
                .padding(.horizontal, isIpad ? 70 : 37)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func privacyPolicyPage() -> some View {
        let screenHeight = UIScreen.main.bounds.height
        
        return VStack {
            GifView("privacy")
                .frame(width: isIpad ? 645 : 430, height: isIpad ? 465 : 310)
                .padding(.top, screenHeight * 0.13)
            
            VStack(alignment: .leading) {
                Text("Privacy Policy")
                    .font(.custom(Fonts.shared.interSemibold, size: isIpad ? 45 : 28))
                    .foregroundColor(Colors.shared.primaryColor)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 16)
                
                Text("By continuing you accept our Privacy Policy and Terms of Use, and permision to your galery.")
                    .font(.custom(Fonts.shared.interRegular, size: isIpad ? 22 : 16))
                    .foregroundStyle(.black.opacity(0.75))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
                
                Spacer()
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        viewModel.showPrivacyPolicy = false
                    }
                }) {
                    Text("Accept All")
                        .font(.custom(Fonts.shared.interSemibold, size: isIpad ? 24 : 20))
                        .foregroundStyle(Color.white)
                        .padding(.vertical, isIpad ? 22 : 16)
                        .frame(maxWidth: .infinity)
                        .background(Colors.shared.primaryColor)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                }
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        viewModel.showPrivacyPolicy = false
                    }
                }) {
                    Text("Refuse")
                        .font(.custom(Fonts.shared.interSemibold, size: isIpad ? 24 : 20))
                        .foregroundColor(Color.gray)
                        .padding(.vertical, isIpad ? 22 : 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                }
            }
            .padding(.horizontal, isIpad ? 70 : 38)
            .padding(.bottom, isIpad ? 40 : 20)
        }
    }
    
    private func faceProcessingPage() -> some View {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        return VStack(alignment: .leading) {
            Text("Face Processing")
                .font(.custom(Fonts.shared.interSemibold, size: 28))
                .padding(.top, screenHeight * 0.03)
                .padding(.horizontal, isIpad ? 70 : 38)
            
            Text("To continue, please upload 8 images of yourself.")
                .font(.custom(Fonts.shared.interRegular, size: 17))
                .foregroundStyle(.black.opacity(0.7))
                .multilineTextAlignment(.leading)
                .padding(.top, 4)
                .padding(.bottom, 15)
                .padding(.horizontal, isIpad ? 70 : 38)
            
            PhotosPicker(
                selection: $viewModel.selectedItems,
                maxSelectionCount: 8,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack {
                    Image("img")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .padding(.bottom, 5)
                    
                    Text("Upload Images")
                        .font(.custom(Fonts.shared.interRegular, size: 17))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color(hex: "#ebebeb"))
                .cornerRadius(12)
                .padding(.horizontal, isIpad ? 70 : 38)
            }
            .onChange(of: viewModel.selectedItems) { newItems in
                Task {
                    viewModel.selectedImages.removeAll()
                    
                    withAnimation {
                        viewModel.isLoading = true
                    }
                    
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            viewModel.selectedImages.append(uiImage)
                        }
                    }
                    
                    Consts.shared.setUploadImages(viewModel.selectedImages)
                    
                    withAnimation {
                        viewModel.isLoading = false
                    }
                }
            }
            
            if viewModel.isLoading {
                VStack {
                    Text("Uploading...")
                        .font(.custom(Fonts.shared.interRegular, size: 17))
                        .foregroundStyle(.black.opacity(0.7))
                    ProgressView()
                }
                .padding(.top, screenHeight * 0.15)
                .frame(maxWidth: .infinity)
            } else {
                TabView(selection: $viewModel.currentUploadedPhotoIndex) {
                    ForEach(0..<viewModel.selectedImages.count, id: \.self) { index in
                        Image(uiImage: viewModel.selectedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 0.5, height: screenHeight * 0.33)
                            .cornerRadius(17)
                            .shadow(radius: 5)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: screenHeight * 0.35)
                .padding(.top, screenHeight * 0.05)
                
                Spacer()
                
                HStack {
                    ForEach(0..<viewModel.selectedImages.count, id: \.self) { index in
                        Rectangle()
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(viewModel.currentUploadedPhotoIndex == index ? Colors.shared.primaryColor : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 70)
                .padding(.top, 10)
            }
            
            Spacer()
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if viewModel.selectedImages.count < 8 { return }
                
                withAnimation {
                    viewModel.showFaceProcessing = false
                    viewModel.showGenerationView = true
                }
            }) {
                ZStack(alignment: .center) {
                    Text("Get Started")
                        .font(.custom(Fonts.shared.interSemibold, size: isIpad ? 24 : 20))
                        .foregroundStyle(Color.white)
                        .padding(.vertical, isIpad ? 22 : 16)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.selectedImages.count < 8 ? Color.gray : Colors.shared.primaryColor)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                    
                    HStack {
                        Spacer()
                        
                        Image("arrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 21, height: 21)
                            .padding(.trailing, 15)
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, isIpad ? 70 : 37)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.requestForAuthorizationIfNecessary()
            }
        }
    }
    
    private func loadingPage() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Analyzing your photos...")
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 28))
                .foregroundStyle(.black)
                .padding(.bottom, 3)
                .padding(.top, 60)
            
            Text("Please wait a few moments")
                .font(.custom(Fonts.shared.interRegular, size: 18))
                .foregroundStyle(.accent)
                .task {
                    try? await UserApi.shared.registerUser()
                    
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    
                    Superwall.shared.register(placement: "campaign_trigger")
                    
                    Consts.shared.completeOnboarding()
                }
            
            LottieView(animation: .named("processing"))
                .looping()
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top)
            
            Spacer()
        }
    }
    
    var body: some View {
        if viewModel.showGenderPicker {
            genderPickerPage()
        } else if viewModel.showPrivacyPolicy {
            privacyPolicyPage()
        } else if viewModel.showFaceProcessing {
            faceProcessingPage()
        } else if viewModel.showGenerationView {
            loadingPage()
        } else {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            VStack {
                TabView(selection: $viewModel.currentPageIndex) {
                    VStack {
                        ZStack {
                            GifView("onboarding1")
                                .scaledToFill()
                                .frame(width: screenWidth, height: screenHeight * 0.75)
                                .clipped()
                            
                            VStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: screenHeight * 0.17)
                                .padding(.top, screenHeight * 0.05)
                                
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: screenHeight * 0.13)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Welcome to")
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: isIpad ? 45 : 26))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            
                            Text("AI Photo Enhancer")
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: isIpad ? 45 : 26))
                                .foregroundStyle(Colors.shared.primaryColor)
                                .multilineTextAlignment(.leading)
                            
                            Text("Welcome to AI Photo Enhancer, where your photos transform into masterpieces with just a tap. Let's embark on a journey of effortless editing.")
                                .font(.custom(Fonts.shared.interRegular, size: isIpad ? 21 : 17))
                                .foregroundStyle(.black.opacity(0.7))
                                .padding(.top, 4)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, isIpad ? 70 : 38)
                        .padding(.bottom, screenHeight * 0.03)
                        
                        Spacer()
                    }
                    .padding(.top, -screenHeight * 0.175)
                    .tag(0)
                    
                    VStack {
                        ZStack {
                            GifView("onboarding2")
                                .clipped()
                            
                            VStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white,
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 160)
                                .padding(.top, -10)
                                
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.85),
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 90)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("AI-Powered")
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: isIpad ? 45 : 26))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            
                            Text("Photo Enhancer")
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: isIpad ? 45 : 26))
                                .foregroundStyle(Colors.shared.primaryColor)
                                .multilineTextAlignment(.leading)
                            
                            Text("Enhance image quality instantly with AI. Sharpen details, improve lighting, and restore clarity — all in one tap. Say goodbye to blurry, dull photos.")
                                .font(.custom(Fonts.shared.interRegular, size: isIpad ? 21 : 17))
                                .foregroundStyle(.black.opacity(0.7))
                                .padding(.top, 4)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, screenWidth * 0.1)
                        .padding(.bottom, 30)
                        
                        Spacer()
                    }
                    .padding(.top, screenHeight * 0.035)
                    .tag(1)
                    
                    VStack {
                        GifView("onboarding3")
                            .scaledToFill()
                            .frame(height: screenHeight * 0.45)
                            .frame(width: screenWidth)
                            .clipped()
                            .padding(.top, screenHeight * 0.475)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Remove Backgrounds")
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: isIpad ? 45 : 26))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            
                            Text("with One Tap")
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: isIpad ? 45 : 26))
                                .foregroundStyle(Colors.shared.primaryColor)
                                .multilineTextAlignment(.leading)
                            
                            Text("Effortlessly erase backgrounds using AI. Perfect for portraits, products, or profile pics — get a clean cutout in seconds, no manual editing needed.")
                                .font(.custom(Fonts.shared.interRegular, size: isIpad ? 21 : 17))
                                .foregroundStyle(.black.opacity(0.7))
                                .padding(.top, 4)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, screenWidth * 0.1)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, -screenHeight * 0.33)
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        if viewModel.currentPageIndex == 2 {
                            viewModel.showGenderPicker = true
                        } else {
                            viewModel.currentPageIndex += 1
                        }
                    }
                }) {
                    ZStack(alignment: .center) {
                        Text("Continue")
                            .font(.custom(Fonts.shared.interSemibold, size: isIpad ? 24 : 20))
                            .foregroundStyle(Color.white)
                            .padding(.vertical, isIpad ? 22 : 16)
                            .frame(maxWidth: .infinity)
                            .background(Colors.shared.primaryColor)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                        
                        HStack {
                            Spacer()
                            
                            Image("arrow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                                .padding(.trailing, 15)
                        }
                    }
                    .padding(.horizontal, isIpad ? 70 : 37)
                    .padding(.bottom, 20)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}
