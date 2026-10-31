import Foundation
import Observation

@Observable
@MainActor
final class PhotoLibrary {
    private(set) var records: [PhotoRecord] = []
    private(set) var storageError: String?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let storageKey = "one-good-thing.photo-library.v1"

    var savedPhotos: [PhotoRecord] {
        records.filter(\.isFavorite).sorted { $0.photo.date > $1.photo.date }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let data = defaults.data(forKey: storageKey) else { return }

        do {
            records = try JSONDecoder().decode([PhotoRecord].self, from: data)
        } catch {
            storageError = "Saved photos couldn't be read: \(error.localizedDescription)"
        }
    }

    func isFavorite(_ photo: AstronomyPhoto) -> Bool {
        records.first(where: { $0.id == photo.id })?.isFavorite ?? false
    }

    func comments(for photo: AstronomyPhoto) -> [PhotoComment] {
        records.first(where: { $0.id == photo.id })?.comments ?? []
    }

    func toggleFavorite(_ photo: AstronomyPhoto) {
        var updated = records
        if let index = updated.firstIndex(where: { $0.id == photo.id }) {
            updated[index].photo = photo
            updated[index].isFavorite.toggle()
            if !updated[index].isFavorite && updated[index].comments.isEmpty {
                updated.remove(at: index)
            }
        } else {
            updated.append(PhotoRecord(photo: photo, isFavorite: true, comments: []))
        }
        save(updated)
    }

    func addComment(_ text: String, to photo: AstronomyPhoto) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        var updated = records
        let comment = PhotoComment(text: trimmedText)
        if let index = updated.firstIndex(where: { $0.id == photo.id }) {
            updated[index].photo = photo
            updated[index].comments.append(comment)
        } else {
            updated.append(PhotoRecord(photo: photo, isFavorite: false, comments: [comment]))
        }
        save(updated)
    }

    func dismissStorageError() {
        storageError = nil
    }

    private func save(_ updated: [PhotoRecord]) {
        do {
            let data = try JSONEncoder().encode(updated)
            defaults.set(data, forKey: storageKey)
            records = updated
            storageError = nil
        } catch {
            storageError = "Your change couldn't be saved: \(error.localizedDescription)"
        }
    }
}
