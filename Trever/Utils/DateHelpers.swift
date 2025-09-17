import Foundation

extension Calendar {
    /// Returns the end of day (24:00 i.e., next day at 00:00) for a given date.
    func endOfDay(for date: Date) -> Date {
        let start = startOfDay(for: date)
        return self.date(byAdding: .day, value: 1, to: start) ?? date
    }
}

/// If server provides date-only (00:00 time), normalize to that day's end (24:00).
/// Otherwise, respect the exact timestamp.
func normalizedAuctionEnd(_ date: Date, calendar: Calendar = .current) -> Date {
    let c = calendar.dateComponents([.hour, .minute, .second], from: date)
    if (c.hour ?? 0) == 0 && (c.minute ?? 0) == 0 && (c.second ?? 0) == 0 {
        return calendar.endOfDay(for: date)
    }
    return date
}
