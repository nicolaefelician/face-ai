import SwiftUI

struct ImageJobCard: View {
    let job: ImageJob
    let showDate: Bool
    
    @State private var imageURLs: [URL] = []
    @ObservedObject private var globalState = GlobalState.shared
    
    private func loadImages() {
        if let data = job.images.data(using: .utf8) {
            do {
                let urls = try JSONDecoder().decode([String].self, from: data)
                imageURLs = urls.compactMap { URL(string: $0) }
            } catch {
                print("❌ Failed to decode images: \(error)")
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: job.creationDate)
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if job.status == .complete {
                globalState.navigationPath.append(.imageFilter(jobId: String(job.id), type: .headshot))
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(job.presetCategory.rawValue)
                        .font(.custom(Fonts.shared.instrumentSansSemibold, size: 15))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                    
                    if showDate {
                        Text(formattedDate)
                            .font(.custom(Fonts.shared.interRegular, size: 13))
                            .foregroundColor(.gray)
                            .padding(.leading, 20)
                    } else {
                        Text(job.status == .processing ? "Processing..." : "Done")
                            .font(.custom(Fonts.shared.interSemibold, size: 13))
                            .foregroundColor(job.status == .processing ? .accentColor : .green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                (job.status == .processing ? Color.accentColor : Color.green)
                                    .opacity(0.1)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 25)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(width: 16)
                        
                        if imageURLs.isEmpty {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#ebebeb"))
                                    .frame(width: 115, height: 165)
                                    .overlay(ProgressView())
                            }
                        } else {
                            ForEach(imageURLs, id: \.self) { url in
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 115, height: 165)
                                            .clipped()
                                            .cornerRadius(12)
                                    } else if phase.error != nil {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "#ebebeb"))
                                            .frame(width: 115, height: 165)
                                            .overlay(Image(systemName: "photo.fill"))
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "#ebebeb"))
                                            .frame(width: 115, height: 165)
                                            .overlay(ProgressView())
                                    }
                                }
                            }
                        }
                        
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(width: 20)
                    }
                }
            }
            .onAppear { loadImages() }
            .padding(.bottom, 15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
