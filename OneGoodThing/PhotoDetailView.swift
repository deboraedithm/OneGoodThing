import SafariServices
import SwiftUI

struct PhotoDetailView: View {
    let photo: AstronomyPhoto

    @Environment(PhotoLibrary.self) private var photoLibrary
    @State private var isShowingComments = false
    @State private var isShowingVideo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if photo.mediaType == .image {
                    AsyncImage(url: photo.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure:
                            unavailableImage
                        case .empty:
                            unavailableImage.overlay { ProgressView().tint(.white) }
                        @unknown default:
                            unavailableImage
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    Button {
                        isShowingVideo = true
                    } label: {
                        unavailableImage
                            .overlay {
                                Label("Watch today's astronomy video", systemImage: "play.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .frame(height: 230)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(photo.date)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                    Text(photo.title)
                        .font(.largeTitle.weight(.bold))
                    if let copyright = photo.copyright, !copyright.isEmpty {
                        Text("Image: \(copyright)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(photo.explanation)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.88))
                    .lineSpacing(5)

                HStack(spacing: 12) {
                    Button {
                        photoLibrary.toggleFavorite(photo)
                    } label: {
                        Label(
                            photoLibrary.isFavorite(photo) ? "Saved" : "Favorite",
                            systemImage: photoLibrary.isFavorite(photo) ? "heart.fill" : "heart"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .tint(.orange)
                    .buttonStyle(.borderedProminent)

                    Button {
                        isShowingComments = true
                    } label: {
                        Label("Comments", systemImage: "text.bubble")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .background(Color(red: 0.035, green: 0.045, blue: 0.09))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingComments) {
            CommentsView(photo: photo)
        }
        .sheet(isPresented: $isShowingVideo) {
            SafariView(url: photo.url)
                .ignoresSafeArea()
        }
    }

    private var unavailableImage: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: [.indigo.opacity(0.7), .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
