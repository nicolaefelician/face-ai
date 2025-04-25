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
        let screenWidth = UIScreen.main.bounds.width

        VStack(spacing: 0) {
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
            .padding(.horizontal, 20)
            .padding(.top)
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
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)

            ScrollView {
                LazyVStack {
                    if viewModel.isAllSelected {
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
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            withAnimation {
                                                globalState.selectedPreset = preset
                                                globalState.showPresetPreview = true
                                            }
                                        }) {
                                            RetryingAsyncImage(
                                                url: URL(string: preset.image)!,
                                                size: CGSize(width: preset.imageSize.width * 1.5, height: imageHeight),
                                                maxRetries: 3,
                                                retryDelay: 1
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                            .padding(.bottom)
                            .frame(height: imageHeight)
                        }
                    } else {
                        let chunkedImages = viewModel.filteredPresets.chunked(into: 2)
                        let horizontalPadding = 22.5
                        let itemSpacing = 7.5
                        let itemWidth = (screenWidth - horizontalPadding * 2 - itemSpacing) / 2

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
                                            RetryingAsyncImage(
                                                url: URL(string: preset.image)!,
                                                size: isIpad
                                                    ? CGSize(width: itemWidth, height: 240 * 2)
                                                    : CGSize(width: itemWidth, height: 240),
                                                maxRetries: 3,
                                                retryDelay: 1
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, screenWidth * 0.02)
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Prompts")
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
    }
}
