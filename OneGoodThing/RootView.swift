import SwiftUI

struct RootView: View {
    @Environment(PhotoLibrary.self) private var photoLibrary

    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "sparkles")
            }

            NavigationStack {
                SavedView()
            }
            .tabItem {
                Label("Saved", systemImage: "heart.fill")
            }
        }
        .tint(.orange)
        .alert(
            "Couldn't update your library",
            isPresented: Binding(
                get: { photoLibrary.storageError != nil },
                set: { if !$0 { photoLibrary.dismissStorageError() } }
            )
        ) {
            Button("OK", role: .cancel) {
                photoLibrary.dismissStorageError()
            }
        } message: {
            Text(photoLibrary.storageError ?? "Please try again.")
        }
    }
}
