import Foundation

protocol APODServicing: Sendable {
    func fetchPhoto(for date: Date) async throws -> AstronomyPhoto
}

struct NASAAPODService: APODServicing {
    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared, apiKey: String? = nil) {
        self.session = session
        self.apiKey = apiKey
            ?? Bundle.main.object(forInfoDictionaryKey: "NASA_API_KEY") as? String
            ?? "DEMO_KEY"
    }

    func fetchPhoto(for date: Date) async throws -> AstronomyPhoto {
        var components = URLComponents(string: "https://api.nasa.gov/planetary/apod")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "date", value: Self.apiDateString(from: date)),
            URLQueryItem(name: "thumbs", value: "true")
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

        return try JSONDecoder().decode(AstronomyPhoto.self, from: data)
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

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The astronomy photo request could not be created."
        case .invalidResponse:
            return "NASA returned an invalid response. Please try again."
        case .httpStatus(let code):
            return "NASA could not load today's photo (HTTP \(code)). Please try again later."
        }
    }
}
