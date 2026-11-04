import Foundation
import Observation

@Observable
@MainActor
final class TodayViewModel {
    private(set) var photo: AstronomyPhoto?
    private(set) var selectedDate = Self.startOfAPODDay(.now)
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    @ObservationIgnored private let service: any APODServicing
    @ObservationIgnored private var lastLoadedAPODDay: Date?
    @ObservationIgnored private var selectionFollowsToday = true

    init(service: any APODServicing) {
        self.service = service
    }

    var earliestAPODDate: Date {
        apodCalendar.date(from: DateComponents(year: 1995, month: 6, day: 16)) ?? .distantPast
    }

    var apodCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar
    }

    var isShowingToday: Bool {
        selectedDate == Self.startOfCurrentAPODDay()
    }

    func selectDate(_ date: Date) {
        let requestedDay = Self.startOfAPODDay(date)
        selectionFollowsToday = requestedDay == Self.startOfCurrentAPODDay()
        guard requestedDay != selectedDate else { return }
        selectedDate = requestedDay
        photo = nil
        errorMessage = nil
    }

    func loadToday(forceRefresh: Bool = false) async {
        selectionFollowsToday = true
        selectDate(.now)
        await loadSelectedDate(forceRefresh: forceRefresh)
    }

    func refreshAfterBecomingActive() async {
        if selectionFollowsToday {
            await loadToday()
        } else {
            await loadSelectedDate()
        }
    }

    func loadSelectedDate(forceRefresh: Bool = false) async {
        let requestedDay = selectedDate
        guard !isLoading, forceRefresh || lastLoadedAPODDay != requestedDay else { return }

        if lastLoadedAPODDay != requestedDay {
            photo = nil
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var dayToLoad = requestedDay
            while true {
                let fetchedPhoto: AstronomyPhoto
                do {
                    fetchedPhoto = try await service.fetchPhoto(for: dayToLoad)
                } catch {
                    let currentDay = Self.startOfCurrentAPODDay()
                    if dayToLoad != selectedDate {
                        dayToLoad = selectedDate
                        continue
                    }
                    if selectionFollowsToday, dayToLoad != currentDay {
                        selectedDate = currentDay
                        dayToLoad = currentDay
                        continue
                    }
                    throw error
                }
                let currentDay = Self.startOfCurrentAPODDay()
                if dayToLoad != selectedDate {
                    dayToLoad = selectedDate
                    continue
                }
                if selectionFollowsToday, dayToLoad != currentDay {
                    selectedDate = currentDay
                    dayToLoad = currentDay
                    continue
                }
                photo = fetchedPhoto
                lastLoadedAPODDay = dayToLoad
                return
            }
        } catch {
            photo = nil
            lastLoadedAPODDay = nil
            errorMessage = error.localizedDescription
        }
    }

    func waitUntilNextAPODDay() async -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        guard let nextDay = calendar.dateInterval(of: .day, for: .now)?.end else {
            return false
        }

        let nanoseconds = UInt64(max(nextDay.timeIntervalSinceNow, 1) * 1_000_000_000)
        do {
            try await Task.sleep(nanoseconds: nanoseconds)
            return true
        } catch {
            return false
        }
    }

    private static func startOfCurrentAPODDay() -> Date {
        startOfAPODDay(.now)
    }

    private static func startOfAPODDay(_ date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar.startOfDay(for: date)
    }
}
