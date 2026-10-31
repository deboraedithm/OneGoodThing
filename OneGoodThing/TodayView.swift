import SwiftUI

struct TodayView: View {
    @Environment(TodayViewModel.self) private var viewModel

    var body: some View {
        Group {
            if let photo = viewModel.photo {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if let errorMessage = viewModel.errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                                .padding(.horizontal)
                        }
                        header
                        NavigationLink {
                            PhotoDetailView(photo: photo)
                        } label: {
                            PhotoPreview(photo: photo)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("TODAY'S UNIVERSE")
                                .font(.caption.weight(.bold))
                                .tracking(1.5)
                                .foregroundStyle(.orange)
                            Text(photo.title)
                                .font(.title2.weight(.bold))
                            Text(photo.explanation)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineLimit(4)
                            NavigationLink("Discover the story") {
                                PhotoDetailView(photo: photo)
                            }
                            .font(.subheadline.weight(.semibold))
                            .tint(.orange)
                            .padding(.top, 4)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 28)
                }
                .refreshable {
                    await viewModel.loadToday(forceRefresh: true)
                }
            } else if viewModel.isLoading {
                ProgressView("Finding today's good thing…")
                    .tint(.orange)
            } else {
                ContentUnavailableView {
                    Label("The sky is quiet", systemImage: "moon.stars")
                } description: {
                    Text(viewModel.errorMessage ?? "Today's photo is not available right now.")
                } actions: {
                    Button("Try again") {
                        Task { await viewModel.loadToday(forceRefresh: true) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
        }
        .background(Color(red: 0.035, green: 0.045, blue: 0.09))
        .navigationBarHidden(true)
        .task {
            await viewModel.loadToday()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ONE GOOD THING")
                .font(.caption.weight(.bold))
                .tracking(2.5)
                .foregroundStyle(.orange)
            Text("A little wonder, every day.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

struct PhotoPreview: View {
    let photo: AstronomyPhoto

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: photo.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imagePlaceholder
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.65))
                        }
                case .empty:
                    imagePlaceholder
                        .overlay { ProgressView().tint(.white) }
                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(height: 340)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.72)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(photo.date)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                Text(photo.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(18)
        }
        .frame(height: 340)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.indigo.opacity(0.8), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
