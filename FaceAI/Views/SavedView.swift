import SwiftUI

struct SavedImageCard: View {
    let image: SavedImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let uiImage = UIImage(data: image.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: isIpad ? 500 : 340)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(18)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 340)
                        .cornerRadius(18)
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
            }
            
            Text(image.creationDate.formatted(date: .abbreviated, time: .shortened))
                .font(.custom(Fonts.shared.interRegular, size: 15))
                .foregroundColor(.gray)
                .padding(.top, 6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 15)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

struct SavedView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = SavedViewModel()
    @ObservedObject private var globalState = GlobalState.shared
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
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
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            ScrollView {
                let screenHeight = UIScreen.main.bounds.height
                
                VStack {
                    if viewModel.filteredList.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray.and.arrow.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No saved images found")
                                .font(.custom(Fonts.shared.interRegular, size: 17))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, screenHeight * 0.3)
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(viewModel.filteredList.sorted(by: { $0.creationDate > $1.creationDate }), id: \.id) { image in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                globalState.selectedImage = UIImage(data: image.imageData)
                                globalState.showFullscreenImage = true
                            }) {
                                SavedImageCard(image: image)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .onTapGesture {
                isFocused = false
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}
