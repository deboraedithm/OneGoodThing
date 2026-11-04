import Foundation

protocol APODServicing: Sendable {
    func fetchPhoto(for date: Date) async throws -> AstronomyPhoto
}

struct NASAAPODService: APODServicing {
    private static let pageSize = 25
    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared, apiKey: String? = nil) {
        self.session = session
        self.apiKey = apiKey
            ?? Bundle.main.object(forInfoDictionaryKey: "NASA_API_KEY") as? String
            ?? "DEMO_KEY"
    }

    func fetchPhoto(for date: Date) async throws -> AstronomyPhoto {
        let requestedDate = Self.apiDateString(from: date)
        let today = Self.startOfAPODDay(.now)
        let selectedDay = Self.startOfAPODDay(date)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let daysBack = max(0, calendar.dateComponents([.day], from: selectedDay, to: today).day ?? 0)
        var page = max(1, daysBack / Self.pageSize + 1)

        while true {
            let photos = try await fetchPage(page)
            if let photo = photos.first(where: { $0.date == requestedDate }) {
                guard photo.mediaType != .other else {
                    throw NASAServiceError.unavailablePhoto(requestedDate)
                }
                return photo
            }

            guard let newestDate = photos.first?.date,
                  let oldestDate = photos.last?.date else {
                throw NASAServiceError.unavailablePhoto(requestedDate)
            }

            if requestedDate > newestDate {
                page = max(1, page - 1)
            } else if requestedDate < oldestDate {
                guard photos.count == Self.pageSize else {
                    throw NASAServiceError.unavailablePhoto(requestedDate)
                }
                page += 1
            } else {
                throw NASAServiceError.unavailablePhoto(requestedDate)
            }
        }
    }

    private func fetchPage(_ page: Int) async throws -> [AstronomyPhoto] {
        var components = URLComponents(string: "https://science.nasa.gov/wp-json/wp/v2/apod-basic/")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw NASAServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw NASAServiceError.invalidResponse
        }
        guard (200..<300).contains(response.statusCode) else {
            throw NASAServiceError.httpStatus(response.statusCode)
        }

        return try JSONDecoder().decode([AstronomyPhoto].self, from: data)
    }

    private static func startOfAPODDay(_ date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar.startOfDay(for: date)
    }

    private static func apiDateString(from date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}

private enum NASAServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case unavailablePhoto(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The astronomy photo request could not be created."
        case .invalidResponse:
            return "NASA returned an invalid response. Please try again."
        case .httpStatus(429):
            return "NASA's API request limit was reached. Please try again later."
        case .httpStatus(let code):
            return "NASA could not load the requested photo (HTTP \(code)). Please try again later."
        case .unavailablePhoto(let date):
            return "NASA did not return an Astronomy Picture of the Day for \(date). Please try again later."
        }
    }
}
