//import SwiftUI
//
//struct SavedImageCard: View {
//    let image: SavedImage
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            AsyncImage(url: image.imageUrl) { phase in
//                switch phase {
//                case .empty:
//                    ZStack {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.1))
//                        ProgressView()
//                    }
//                    .frame(height: 340)
//                    .cornerRadius(18)
//
//                case .success(let loadedImage):
//                    loadedImage
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 340)
//                        .frame(maxWidth: .infinity)
//                        .clipped()
//                        .cornerRadius(18)
//
//                case .failure:
//                    Image(systemName: "xmark.octagon.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 80)
//                        .foregroundColor(.red)
//                        .padding()
//
//                @unknown default:
//                    EmptyView()
//                }
//            }
//
//            Text(image.presetCategory.rawValue)
//                .font(.custom(Fonts.shared.interSemibold, size: 15))
//                .foregroundColor(.black)
//
//            Text(image.creationDate.formatted(date: .abbreviated, time: .shortened))
//                .font(.custom(Fonts.shared.interRegular, size: 13))
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 0) // 💥 full card shadow
//        )
//        .padding(.horizontal, 20)
//        .padding(.top, 10)
//    }
//}
//
//struct SavedView: View {
//    @Environment(\.presentationMode) var presentationMode
//    
//    @StateObject private var viewModel = SavedViewModel()
//    @ObservedObject private var globalState = GlobalState.shared
//    
//    @FocusState var isFocused: Bool
//    
//    var body: some View {
//        ScrollView {
//            VStack {
//                HStack {
//                    Image("search")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 25, height: 25)
//                    
//                    TextField("Search", text: $viewModel.inputText)
//                        .padding(.horizontal, 8)
//                        .font(.custom(Fonts.shared.interRegular, size: 17))
//                        .focused($isFocused)
//                }
//                .padding(.vertical, 11)
//                .padding(.horizontal)
//                .frame(maxWidth: .infinity)
//                .background(Color(hex: "#ebebeb"))
//                .cornerRadius(24)
//                .padding(.horizontal, 20)
//                
//                if viewModel.filteredList.isEmpty {
//                    VStack(spacing: 12) {
//                        Image(systemName: "tray.and.arrow.down")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(.gray.opacity(0.6))
//                        
//                        Text("No saved images found")
//                            .font(.custom(Fonts.shared.interRegular, size: 17))
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.top, 60)
//                    .frame(maxWidth: .infinity)
//                } else {
//                    ForEach(viewModel.filteredList.sorted { $0.creationDate > $1.creationDate }, id: \.imageUrl) { image in
//                        Button(action: {
//                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                            globalState.selectedImageUrl = image.imageUrl
//                            globalState.showFullscreenImage = true
//                        }) {
//                            SavedImageCard(image: image)
//                        }
//                    }
//                }
//            }
//            .padding(.vertical)
//        }
//        .onTapGesture {
//            isFocused = false
//        }
//        .navigationTitle("Saved")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image("back")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 28, height: 28)
//                }
//            }
//        }
//    }
//}
