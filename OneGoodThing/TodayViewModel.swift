import Foundation
import Observation

@Observable
@MainActor
final class TodayViewModel {
    private(set) var photo: AstronomyPhoto?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    @ObservationIgnored private let service: any APODServicing

    init(service: any APODServicing) {
        self.service = service
    }

    func loadToday(forceRefresh: Bool = false) async {
        guard !isLoading, forceRefresh || photo == nil else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            photo = try await service.fetchPhoto(for: .now)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
