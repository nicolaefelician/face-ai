import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = HistoryViewModel()
    @FocusState var isFocused: Bool
    
    var body: some View {
        ScrollView {
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
            .padding(.horizontal, 22.5)
            .padding(.top)
            
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.selectedItemIndex = 0
                }) {
                    Text("Headshots")
                        .font(.custom(Fonts.shared.interSemibold, size: 16))
                        .foregroundStyle(viewModel.selectedItemIndex == 0 ? .white : Color(hex: "#797979"))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedItemIndex == 0 ? Colors.shared.primaryColor : Color(hex: "#f2f2f2"))
                        .cornerRadius(25)
                }
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.selectedItemIndex = 1
                }) {
                    Text("Filters")
                        .font(.custom(Fonts.shared.interSemibold, size: 16))
                        .foregroundStyle(viewModel.selectedItemIndex == 1 ? .white : Color(hex: "#797979"))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedItemIndex == 1 ? Colors.shared.primaryColor : Color(hex: "#f2f2f2"))
                        .cornerRadius(25)
                }
                
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 15)
            .padding(.horizontal, 22.5)
            
            if viewModel.selectedItemIndex == 0 {
                if viewModel.filteredPresets.isEmpty {
                    emptyHistoryView()
                } else {
                    ForEach(viewModel.filteredPresets.sorted(by: { $0.creationDate > $1.creationDate })) { job in
                        ImageJobCard(job: job, showDate: true)
                    }
                }
            } else {
                if viewModel.filteredEnhanceJobs.isEmpty {
                    emptyHistoryView()
                } else {
                    ForEach(viewModel.filteredEnhanceJobs.sorted(by: { $0.createdAt > $1.createdAt })) { job in
                        EnhanceJobCard(job: job, showDate: true)
                                .padding(.bottom, 7)
                                .padding(.horizontal, 2)
                    }
                }
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .navigationTitle("History")
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
    
    private func emptyHistoryView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No history found")
                .font(.custom(Fonts.shared.interRegular, size: 17))
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}
