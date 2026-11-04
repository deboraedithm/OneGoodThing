import SwiftUI

struct RootView: View {
    @Environment(PhotoLibrary.self) private var photoLibrary
    @Environment(TodayViewModel.self) private var todayViewModel
    @Environment(\.scenePhase) private var scenePhase

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
        .task {
            while !Task.isCancelled {
                guard await todayViewModel.waitUntilNextAPODDay() else { return }
                await todayViewModel.loadToday(forceRefresh: true)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                await todayViewModel.refreshAfterBecomingActive()
            }
        }
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
