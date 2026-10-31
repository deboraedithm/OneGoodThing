import SwiftUI

struct CommentsView: View {
    let photo: AstronomyPhoto

    @Environment(PhotoLibrary.self) private var photoLibrary
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @FocusState private var isDraftFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if photoLibrary.comments(for: photo).isEmpty {
                    ContentUnavailableView(
                        "Start the conversation",
                        systemImage: "text.bubble",
                        description: Text("Add a thought about today's discovery.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List(photoLibrary.comments(for: photo)) { comment in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(comment.text)
                                .foregroundStyle(.primary)
                            Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.white.opacity(0.04))
                    }
                    .scrollContentBackground(.hidden)
                }

                HStack(alignment: .bottom, spacing: 10) {
                    TextField("Share a thought…", text: $draft, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .focused($isDraftFocused)
                        .accessibilityLabel("Your comment")

                    Button("Post") {
                        photoLibrary.addComment(draft, to: photo)
                        if photoLibrary.storageError == nil {
                            draft = ""
                            isDraftFocused = false
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .tint(.orange)
                }
                .padding()
                .background(.bar)
            }
            .background(Color(red: 0.035, green: 0.045, blue: 0.09))
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
