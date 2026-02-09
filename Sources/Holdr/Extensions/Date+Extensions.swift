import Foundation

extension Date {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    /// Returns a smart date string for UI display.
    /// - Parameter current: The date to compare against (defaults to now).
    /// - Returns: Time for today, "Yesterday" for yesterday, Short Date for others.
    func smartDateString(relativeTo current: Date = Date()) -> String {
        let calendar = Calendar.current

        if calendar.isDate(self, inSameDayAs: current) {
            return Self.timeFormatter.string(from: self)
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: current),
           calendar.isDate(self, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        return Self.shortDateFormatter.string(from: self)
    }

    /// Returns a verbose description for accessibility.
    /// - Parameter current: The date to compare against (defaults to now).
    /// - Returns: "at Time" for today, "yesterday at Time", or "on Date at Time".
    func accessibilityDateDescription(relativeTo current: Date = Date()) -> String {
        let calendar = Calendar.current
        let time = Self.timeFormatter.string(from: self)

        if calendar.isDate(self, inSameDayAs: current) {
            return "at \(time)"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: current),
           calendar.isDate(self, inSameDayAs: yesterday) {
            return "yesterday at \(time)"
        }

        let date = Self.fullDateFormatter.string(from: self)
        return "on \(date) at \(time)"
    }
}
