import Foundation

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date ?? self
    }

    func formatted(as style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }

    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute],
            from: self,
            to: now
        )

        if let years = components.year, years > 0 {
            return years == 1 ? "há 1 ano" : "há \(years) anos"
        }
        if let months = components.month, months > 0 {
            return months == 1 ? "há 1 mês" : "há \(months) meses"
        }
        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "há 1 semana" : "há \(weeks) semanas"
        }
        if let days = components.day, days > 0 {
            return days == 1 ? "há 1 dia" : "há \(days) dias"
        }
        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "há 1 hora" : "há \(hours) horas"
        }
        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "há 1 minuto" : "há \(minutes) minutos"
        }
        return "agora"
    }
}
