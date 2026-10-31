import Foundation

struct AstronomyPhoto: Decodable, Identifiable, Equatable, Sendable {
    let date: String
    let title: String
    let explanation: String
    let url: URL
    let hdURL: URL?
    let mediaType: MediaType
    let copyright: String?

    var id: String { date }
    var imageURL: URL { hdURL ?? url }

    enum MediaType: String, Decodable, Sendable {
        case image
        case video
        case other

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = MediaType(rawValue: value) ?? .other
        }
    }

    private enum CodingKeys: String, CodingKey {
        case date
        case title
        case explanation
        case url
        case hdURL = "hdurl"
        case mediaType = "media_type"
        case copyright
    }
}

struct PhotoComment: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = .now) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

struct PhotoRecord: Codable, Identifiable, Equatable, Sendable {
    var photo: AstronomyPhoto
    var isFavorite: Bool
    var comments: [PhotoComment]

    var id: String { photo.id }
}
