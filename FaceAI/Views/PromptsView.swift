import SwiftUI

struct PromptsView: View {
    @StateObject private var viewModel = PromptsViewModel()
    
    @ObservedObject private var globalState = GlobalState.shared
    
    let presetCategory: PresetCategory?
    
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var isFocused: Bool
    
    private func categoryCard(_ category: PresetCategory) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            viewModel.selectedCategory = category
            viewModel.filterPresets()
            viewModel.isAllSelected = false
        }) {
            Text(category.rawValue)
                .font(.custom(Fonts.shared.interSemibold, size: 15))
                .foregroundStyle(viewModel.selectedCategory == category ? Color.white : Color(hex: "#797979"))
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(viewModel.selectedCategory == category ? Colors.shared.primaryColor : Color(hex: "#f2f2f2"))
                .cornerRadius(25)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Image("search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    
                    TextField("Search", text: $viewModel.inputText)
                        .padding(.horizontal, 8)
                        .font(.custom(Fonts.shared.interRegular, size: 17))
                        .focused($isFocused)
                }
                .padding(.vertical, 11)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#ebebeb"))
                .cornerRadius(24)
                .padding()
                .onAppear {
                    if let category = presetCategory {
                        viewModel.selectedCategory = category
                        viewModel.filterPresets()
                        viewModel.isAllSelected = false
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            viewModel.selectedCategory = nil
                            viewModel.isAllSelected = true
                        }) {
                            Text("All")
                                .font(.custom(Fonts.shared.interSemibold, size: 15))
                                .foregroundStyle(viewModel.isAllSelected ? Color.white : Color(hex: "#797979"))
                                .padding(.horizontal, 17)
                                .padding(.vertical, 8)
                                .background(viewModel.isAllSelected ? Colors.shared.primaryColor : Color(hex: "#f2f2f2"))
                                .cornerRadius(25)
                        }
                        ForEach(PresetCategory.allCases, id: \.self) { category in
                            categoryCard(category)
                        }
                    }
                    .padding(.horizontal)
                }
                
                if viewModel.isAllSelected {
                    VStack(spacing: 0) {
                        ForEach(viewModel.filteredCategories) { category in
                            let presets = imagePresets.filter { $0.category == category }
                            
                            HStack {
                                Text(category.rawValue)
                                    .font(.custom(Fonts.shared.instrumentSansSemibold, size: 22))
                                    .foregroundStyle(.black)
                                Spacer()
                            }
                            .padding(25)
                            
                            let imageHeight = CGFloat(presets[0].imageSize.height * 1.5)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 7.5) {
                                    ForEach(presets, id: \.image) { preset in
                                        let imageWidth = preset.imageSize.width * 1.5
                                        
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            withAnimation {
                                                globalState.selectedPreset = preset
                                                globalState.showPresetPreview = true
                                            }
                                        }) {
                                            AsyncImage(url: URL(string: preset.image)!) { phase in
                                                if phase.error != nil {
                                                    Image(systemName: "photo.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.gray)
                                                        .frame(width: 50, height: 50)
                                                        .frame(width: imageWidth, height: imageHeight)
                                                        .background(Color(.systemGray5))
                                                        .cornerRadius(15)
                                                } else if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: imageWidth, height: imageHeight)
                                                        .cornerRadius(15)
                                                        .clipped()
                                                } else {
                                                    ProgressView()
                                                        .frame(width: imageWidth, height: imageHeight)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                            .padding(.bottom)
                            .frame(height: imageHeight)
                        }
                    }
                } else {
                    let chunkedImages = viewModel.filteredPresets.chunked(into: 2)
                    let horizontalPadding = 22.5
                    let itemSpacing = 7.5
                    let itemWidth = (UIScreen.main.bounds.width - horizontalPadding * 2 - itemSpacing) / 2
                    
                    LazyVStack(spacing: 7.5) {
                        ForEach(0..<chunkedImages.count, id: \.self) { i in
                            HStack(spacing: itemSpacing) {
                                ForEach(chunkedImages[i], id: \.image) { preset in
                                    Button(action: {
                                        globalState.selectedPreset = preset
                                        withAnimation {
                                            globalState.showPresetPreview = true
                                        }
                                    }) {
                                        AsyncImage(url: URL(string: preset.image)) { phase in
                                            Group {
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } else if phase.error != nil {
                                                    ZStack {
                                                        Color(.systemGray5)
                                                        Image(systemName: "exclamationmark.triangle.fill")
                                                            .foregroundColor(.orange)
                                                            .font(.system(size: 30))
                                                    }
                                                } else {
                                                    ZStack {
                                                        Color(.systemGray5)
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                            .frame(width: itemWidth, height: 240)
                                            .clipped()
                                            .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Prompts")
    }
}
