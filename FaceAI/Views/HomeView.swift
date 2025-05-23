import SwiftUI
import PhotosUI
import SuperwallKit

struct HomeView: View {
    @ObservedObject private var globalState = GlobalState.shared
    @ObservedObject private var photoLibraryService = PhotoLibraryService.shared
    
    @StateObject private var viewModel = HomeViewModel()
    
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
                    
                    HStack {
                        Text("Ghibli Style")
                            .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                            .foregroundStyle(.black)
                        Spacer()
                    }
                    .padding(25)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        PhotosPicker(
                            selection: $viewModel.selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            HStack(spacing: 7.5) {
                                ForEach(ghibliImages, id: \.self) { imageUrl in
                                    RetryingAsyncImage(
                                        url: imageUrl,
                                        size: CGSize(width: isIpad ? 115 * 2 : 115, height: isIpad ? 165 * 2 : 165),
                                        maxRetries: 3,
                                        retryDelay: 1.5
                                    )
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                        .onChange(of: viewModel.selectedItem) { newItem in
                            guard let newItem = newItem else { return }
                            
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    withAnimation {
                                        globalState.selectedFilterType = .ghibli
                                        globalState.selectedImage = uiImage
                                        globalState.showImageFilter = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .frame(height: isIpad ? 165 * 2 : 165)
                    
                    HStack {
                        Text("Action Figure")
                            .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                            .foregroundStyle(.black)
                        Spacer()
                    }
                    .padding(25)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7.5) {
                            ForEach(actionFigures, id: \.self) { imageUrl in
                                Button(action: {
                                    Task {
                                        do {
                                            let (imageData, _) = try await safeSession().data(from: imageUrl)
                                            
                                            let image = UIImage(data: imageData)
                                            
                                            withAnimation {
                                                globalState.selectedImage = image
                                                globalState.showActionFigurePopup = true
                                            }
                                        } catch {
                                            print("\(error.localizedDescription)")
                                        }
                                    }
                                }) {
                                    RetryingAsyncImage(
                                        url: imageUrl,
                                        size: CGSize(width: isIpad ? 115 * 2 : 115, height: isIpad ? 165 * 2 : 165),
                                        maxRetries: 3,
                                        retryDelay: 1.5
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.bottom, 10)
                    .frame(height: isIpad ? 165 * 2 : 165)
                    
                    ForEach(PresetCategory.allCases) { category in
                        let images = imagePresets.filter { $0.category == category }
                        
                        HStack {
                            Text(category.rawValue)
                                .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                                .foregroundStyle(.black)
                            Spacer()
                            
                            Button(action: {
                                globalState.navigationPath.append(.prompts(category: category))
                            }) {
                                HStack {
                                    Text("View all")
                                        .font(.custom(Fonts.shared.instrumentSansSemibold, size: 15))
                                    
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                }
                                .foregroundColor(.accentColor)
                            }
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
                                            size: isIpad
                                            ? CGSize(width: preset.imageSize.width * 2, height: preset.imageSize.height * 2)
                                            : preset.imageSize,
                                            maxRetries: 3,
                                            retryDelay: 1.5
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                        .padding(.bottom, 10)
                        .frame(height: isIpad ? (images.first?.imageSize.height ?? 150) * 2 : (images.first?.imageSize.height ?? 150))
                    }
                }
                .padding(.bottom)
                .onTapGesture {
                    print("ON tap gesture")
                    if globalState.showMenu {
                        withAnimation {
                            globalState.showMenu = false
                        }
                    }
                }
            }
            .disabled(globalState.showMenu)
            
            if globalState.showMenu {
                Rectangle()
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        withAnimation {
                            globalState.showMenu = false
                        }
                    }
                
                SideMenuView()
            }
        }
    }
}
