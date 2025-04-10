import SwiftUI
import PhotosUI
import SuperwallKit

struct HomeView: View {
    @ObservedObject private var globalState = GlobalState.shared
    @ObservedObject private var photoLibraryService = PhotoLibraryService.shared
    
    @StateObject private var viewModel = HomeViewModel()
    
    private struct RetryingAsyncImage: View {
        let url: URL
        let size: CGSize
        let maxRetries: Int
        let retryDelay: TimeInterval
        
        @State private var retryCount = 0
        @State private var reloadToken = UUID()
        
        var body: some View {
            AsyncImage(url: urlWithToken) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size.width, height: size.height)
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .cornerRadius(12)
                        .clipped()
                    
                case .failure:
                    Color.clear
                        .onAppear {
                            if retryCount < maxRetries {
                                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                    retryCount += 1
                                    reloadToken = UUID()
                                }
                            }
                        }
                        .overlay(
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: 50, height: 50)
                                .frame(width: size.width, height: size.height)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        )
                    
                @unknown default:
                    EmptyView()
                }
            }
        }
        
        private var urlWithToken: URL {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = (components.queryItems ?? []) + [
                URLQueryItem(name: "reloadToken", value: reloadToken.uuidString)
            ]
            return components.url!
        }
    }
    
    private func ongoingHeader() -> some View {
        HStack {
            Text("Ongoing generation")
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.top)
        .padding(.bottom, 15)
    }
    
    private func historyHeader() -> some View {
        HStack {
            Text("History")
                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                .foregroundStyle(.black)
            
            Spacer()
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                globalState.navigationPath.append(.history)
            }) {
                HStack(spacing: 4) {
                    Text("View all")
                        .font(.custom(Fonts.shared.interSemibold, size: 16))
                        .foregroundColor(Colors.shared.primaryColor)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.shared.primaryColor)
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.top)
        .padding(.bottom, 15)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            globalState.selectedFilterType = .enhance
                        }) {
                            Text("Enhance")
                                .font(.custom(Fonts.shared.interSemibold, size: 16))
                                .foregroundStyle(globalState.selectedFilterType == .enhance ? .white : Color(hex: "#797979"))
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
                                .background(globalState.selectedFilterType == .enhance ? Colors.shared.primaryColor : Color(hex: "#f2f2f2"))
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            globalState.selectedFilterType = .removeBackground
                        }) {
                            Text("Remove Background")
                                .font(.custom(Fonts.shared.interSemibold, size: 16))
                                .foregroundStyle(globalState.selectedFilterType == .removeBackground ? .white : Color(hex: "#797979"))
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
                                .background(globalState.selectedFilterType == .removeBackground ? Colors.shared.primaryColor : Color(hex: "#f2f2f2"))
                                .cornerRadius(25)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 25)
                    
                    if !photoLibraryService.results.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(photoLibraryService.results.suffix(5), id: \.self) { asset in
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation {
                                        globalState.selectedImageId = asset.localIdentifier
                                        globalState.showImageFilter = true
                                    }
                                } label: {
                                    PhotoThumbnailView(assetLocalId: asset.localIdentifier)
                                        .scaledToFill()
                                        .frame(height: 70)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 4) {
                            ForEach(photoLibraryService.results.prefix(4), id: \.self) { asset in
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation {
                                        globalState.selectedImageId = asset.localIdentifier
                                        globalState.showImageFilter = true
                                    }
                                } label: {
                                    PhotoThumbnailView(assetLocalId: asset.localIdentifier)
                                        .scaledToFill()
                                        .frame(height: 70)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(10)
                                }
                            }
                            
                            PhotosPicker(
                                selection: $viewModel.selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                VStack {
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 33, height: 33)
                                        .foregroundColor(Color(hex: "#8d8d8d"))
                                }
                                .frame(height: 70)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#ebebeb"))
                                .cornerRadius(10)
                            }
                            .onChange(of: viewModel.selectedItem) { newItem in
                                guard let newItem = newItem else { return }
                                
                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        withAnimation {
                                            globalState.selectedImage = uiImage
                                            globalState.showImageFilter = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    
                    if globalState.historyJobs.contains(where: { $0.status == .processing }) ||
                        globalState.enhanceJobs.contains(where: { $0.status == .processing }) {
                        
                        ongoingHeader()
                        
                        if let job = globalState.historyJobs.last(where: { $0.status == .processing }) {
                            ImageJobCard(job: job, showDate: false)
                        }
                        
                        if let enhanceJob = globalState.enhanceJobs.last(where: { $0.status == .processing }) {
                            EnhanceJobCard(job: enhanceJob, showDate: false)
                        }
                    }
                    
                    if globalState.historyJobs.contains(where: { $0.status == .complete }) ||
                        globalState.enhanceJobs.contains(where: { $0.status == .successful || $0.status == .failed }) {
                        historyHeader()
                        
                        if let job = globalState.historyJobs.last, job.status == .complete {
                            ImageJobCard(job: job, showDate: true)
                        }
                        
                        if let enhanceJob = globalState.enhanceJobs.last(where: {
                            $0.status == .successful || $0.status == .failed
                        }) {
                            EnhanceJobCard(job: enhanceJob, showDate: true)
                        }
                    }
                    
                    ForEach(PresetCategory.allCases) { category in
                        let images = imagePresets.filter { $0.category == category }
                        
                        HStack {
                            Text(category.rawValue)
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        .padding(25)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7.5) {
                                ForEach(images.prefix(5), id: \.image) { preset in
                                    Button(action: {
                                        withAnimation {
                                            globalState.selectedPreset = preset
                                            globalState.showPresetPreview = true
                                        }
                                    }) {
                                        RetryingAsyncImage(
                                            url: URL(string: preset.image)!,
                                            size: preset.imageSize,
                                            maxRetries: 3,
                                            retryDelay: 1.5
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                        .padding(.bottom, 10)
                        .frame(height: images.first?.imageSize.height ?? 150)
                    }
                }
                .padding(.bottom)
            }
            .disabled(globalState.showMenu)
            
            if globalState.showMenu {
                SideMenuView()
            }
        }
    }
}
