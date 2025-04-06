import SwiftUI

struct EnhanceJobCard: View {
    let job: EnhanceJob
    let showDate: Bool
    
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            globalState.navigationPath.append(.imageFilter(jobId: job.id, type: .filter))
        }) {
            HStack(alignment: .center, spacing: 3) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.status == .successful ? "Filter applied" : "Applying filter...")
                        .font(.custom(Fonts.shared.interRegular, size: 14))
                        .foregroundColor(.gray)
                    
                    if showDate {
                        Text(job.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.custom(Fonts.shared.interRegular, size: 13))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                
                if job.status != .successful {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(0.9)
                }
                
                Spacer()
                
                Text(job.status.text)
                    .font(.custom(Fonts.shared.interSemibold, size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(job.status.color.opacity(0.15))
                    .foregroundColor(job.status.color)
                    .clipShape(Capsule())
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.08), radius: 25, x: 0, y: 0)
            .padding(.horizontal, 22.5)
            .transition(.opacity)
        }
    }
}
