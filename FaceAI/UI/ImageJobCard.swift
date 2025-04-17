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
        GeometryReader { geo in
            let isWide = geo.size.width > 700
            let imageWidth = isWide ? geo.size.width * 0.22 : 115.0
            let imageHeight = isWide ? geo.size.width * 0.3 : 165.0

            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if job.status == .complete {
                    globalState.navigationPath.append(.imageFilter(jobId: String(job.id), type: .headshot))
                }
            }) {
                VStack(alignment: .leading, spacing: 12) {
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
                        HStack(spacing: 12) {
                            if imageURLs.isEmpty {
                                ForEach(0..<4, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#ebebeb"))
                                        .frame(width: imageWidth, height: imageHeight)
                                        .overlay(ProgressView())
                                }
                            } else {
                                ForEach(imageURLs, id: \.self) { url in
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: imageWidth, height: imageHeight)
                                                .clipped()
                                                .cornerRadius(12)
                                        } else if phase.error != nil {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "#ebebeb"))
                                                .frame(width: imageWidth, height: imageHeight)
                                                .overlay(Image(systemName: "photo.fill"))
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "#ebebeb"))
                                                .frame(width: imageWidth, height: imageHeight)
                                                .overlay(ProgressView())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                .onAppear { loadImages() }
                .padding(.bottom, 20)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 300)
    }
}
