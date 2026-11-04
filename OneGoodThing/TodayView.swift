import SwiftUI

struct TodayView: View {
    @Environment(TodayViewModel.self) private var viewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                dateSelector

                if let photo = viewModel.photo {
                    NavigationLink {
                        PhotoDetailView(photo: photo)
                    } label: {
                        PhotoPreview(photo: photo)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.isShowingToday ? "TODAY'S UNIVERSE" : "ON THIS DAY")
                            .font(.caption.weight(.bold))
                            .tracking(1.5)
                            .foregroundStyle(.orange)
                        Text(photo.title)
                            .font(.title2.weight(.bold))
                        Text(photo.plainExplanation)
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
                } else if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView {
                            Text("Finding the photo for \(formattedAPODDate(viewModel.selectedDate))…")
                        }
                        .tint(.orange)
                        Spacer()
                    }
                    .padding(.top, 36)
                } else {
                    ContentUnavailableView {
                        Label("The sky is quiet", systemImage: "moon.stars")
                    } description: {
                        Text(viewModel.errorMessage ?? "No astronomy photo is available for this date.")
                    } actions: {
                        Button("Try again") {
                            Task { await viewModel.loadSelectedDate(forceRefresh: true) }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                }
            }
            .padding(.bottom, 28)
        }
        .refreshable {
            await viewModel.loadSelectedDate(forceRefresh: true)
        }
        .background(Color(red: 0.035, green: 0.045, blue: 0.09))
        .navigationBarHidden(true)
        .task {
            await viewModel.loadSelectedDate()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ONE GOOD THING")
                .font(.caption.weight(.bold))
                .tracking(2.5)
                .foregroundStyle(.orange)
            TimelineView(.periodic(from: .now, by: 60)) { context in
                Text(formattedAPODDate(context.date))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private var dateSelector: some View {
        HStack(spacing: 12) {
            DatePicker(
                "Photo date",
                selection: Binding(
                    get: { viewModel.selectedDate },
                    set: { viewModel.selectDate($0) }
                ),
                in: viewModel.earliestAPODDate...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .tint(.orange)
            .environment(\.timeZone, TimeZone(secondsFromGMT: 0) ?? .current)
            .environment(\.calendar, viewModel.apodCalendar)
            .disabled(viewModel.isLoading)

            Spacer(minLength: 0)

            Button {
                Task { await viewModel.loadSelectedDate(forceRefresh: true) }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Show photo")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(viewModel.isLoading)
        }
        .font(.subheadline)
        .padding(.horizontal)
    }

    private func formattedAPODDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct PhotoPreview: View {
    let photo: AstronomyPhoto

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if photo.mediaType == .image {
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
            } else {
                imagePlaceholder
                    .overlay {
                        Label("Open APOD media", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.85))
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
