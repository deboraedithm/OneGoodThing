import SwiftUI

@main
struct OneGoodThingApp: App {
    @State private var photoLibrary = PhotoLibrary()
    @State private var todayViewModel = TodayViewModel(service: NASAAPODService())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(photoLibrary)
                .environment(todayViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
