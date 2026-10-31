import SwiftUI

struct SavedView: View {
    @Environment(PhotoLibrary.self) private var photoLibrary

    var body: some View {
        Group {
            if photoLibrary.savedPhotos.isEmpty {
                ContentUnavailableView(
                    "No saved wonders yet",
                    systemImage: "heart",
                    description: Text("Tap the heart on a daily photo to keep it here.")
                )
            } else {
                List(photoLibrary.savedPhotos) { record in
                    NavigationLink {
                        PhotoDetailView(photo: record.photo)
                    } label: {
                        HStack(spacing: 14) {
                            AsyncImage(url: record.photo.imageURL) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.indigo.opacity(0.35))
                                    .overlay {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                            }
                            .frame(width: 76, height: 76)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 5) {
                                Text(record.photo.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text(record.photo.date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !record.comments.isEmpty {
                                    Label(
                                        "\(record.comments.count)",
                                        systemImage: "text.bubble"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color(red: 0.035, green: 0.045, blue: 0.09))
        .navigationTitle("Saved wonders")
        .navigationBarTitleDisplayMode(.large)
    }
}
