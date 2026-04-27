import Foundation

enum DateFormatting {
    /// `YYYYMMDD HH:MM:SS:CS` where `CS` is centiseconds (00–99).
    static func instrumentTimestamp(date: Date) -> String {
        let parts = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond],
            from: date
        )
        let cs = ((parts.nanosecond ?? 0) / 10_000_000) % 100
        return String(
            format: "%04d%02d%02d %02d:%02d:%02d:%02d",
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0,
            parts.hour ?? 0,
            parts.minute ?? 0,
            parts.second ?? 0,
            cs
        )
    }

    /// `session-YYYYMMDDTHHMMSSZ.csv` — UTC, no separators.
    static func sessionFilename(for date: Date = Date()) -> String {
        return "session-\(sessionStampFormatter.string(from: date)).csv"
    }

    static let sessionStampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return f
    }()

    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Reverses `sessionFilename` to recover a session's start time.
    static func sessionDate(from filename: String) -> Date? {
        let stem = filename
            .replacingOccurrences(of: "session-", with: "")
            .replacingOccurrences(of: ".csv", with: "")
        return sessionStampFormatter.date(from: stem)
    }

    /// Compact `YYYYMMDD — WEEKDAY` for the History view headers.
    static func dayHeader(date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd ' — ' EEEE"
        return f.string(from: date).uppercased()
    }

    static func clockHM(date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    static func clockHMS(date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }

    /// Duration formatted `HH:MM:SS` — for the active-window chip on
    /// the scrubber. Always integer-second granularity.
    static func durationHMS(seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
