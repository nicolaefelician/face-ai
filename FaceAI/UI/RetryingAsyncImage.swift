import SwiftUI

struct RetryingAsyncImage: View {
    let url: URL
    let size: CGSize
    let maxRetries: Int
    let retryDelay: TimeInterval

    @State private var retryCount = 0
    @State private var reloadToken = UUID()

    var body: some View {
        AsyncImage(url: urlWithToken) { phase in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: size.width, height: size.height)

                switch phase {
                case .empty:
                    ProgressView()

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .cornerRadius(12)
                        .clipped()

                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .onAppear {
                            if retryCount < maxRetries {
                                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                    retryCount += 1
                                    reloadToken = UUID()
                                }
                            }
                        }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: size.width, height: size.height)
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
