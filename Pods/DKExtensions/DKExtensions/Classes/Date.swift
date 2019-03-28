import UIKit

public extension Date {
    
    func string(with format: String = "YYYY-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func from(string: String, format: String = "YYYY-MM-dd") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string) ?? Date()
    }
    
    // Components
    
    func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
    
    var era: Int {
        return component(.era)
    }
    
    var year: Int {
        return component(.year)
    }
    
    var month: Int {
        return component(.month)
    }
    
    var day: Int {
        return component(.day)
    }
    
    var hours: Int {
        return component(.hour)
    }
    
    var minutes: Int {
        return component(.minute)
    }
    
    var seconds: Int {
        return component(.second)
    }
    
    var nanoseconds: Int {
        return component(.nanosecond)
    }
    
    var weekday: Int {
        return component(.weekday)
    }
    
    var weekdayOrdinal: Int {
        return component(.weekdayOrdinal)
    }
    
    var quarter: Int {
        return component(.quarter)
    }
    
    var weekOfMonth: Int {
        return component(.weekOfMonth)
    }
    
    var weekOfYear: Int {
        return component(.weekOfYear)
    }
    
    var yearForWeekOfYear: Int {
        return component(.yearForWeekOfYear)
    }
    
    var calendar: Int {
        return component(.calendar)
    }
    
    var timeZone: Int {
        return component(.timeZone)
    }
    
    
    
    // Adding
    
    func addYears(_ years: Int) -> Date {
        var comps = DateComponents()
        comps.year = years
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    func addMonths(_ months: Int) -> Date {
        var comps = DateComponents()
        comps.month = months
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    
    func addDays(_ days: Int) -> Date {
        var comps = DateComponents()
        comps.day = days
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    func addHours(_ hours: Int) -> Date {
        var comps = DateComponents()
        comps.hour = hours
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    func addMinutes(_ minutes: Int) -> Date {
        var comps = DateComponents()
        comps.minute = minutes
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    func addSeconds(_ seconds: Int) -> Date {
        var comps = DateComponents()
        comps.second = seconds
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    func addWeeks(_ weeks: Int) -> Date {
        var comps = DateComponents()
        comps.weekOfYear = weeks
        return Calendar.current.date(byAdding: comps, to: self) ?? self
    }
    
    var startOfDay: Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var startOfWeek: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.month, .year], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        var comps = DateComponents()
        comps.weekOfYear = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: startOfWeek) ?? self
    }
    
    var endOfMonth: Date {
        var comps = DateComponents()
        comps.month = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: startOfMonth) ?? self
    }
    
    var endOfYear: Date {
        var comps = DateComponents()
        comps.year = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: startOfYear) ?? self
    }
 
    
    var utc: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy HH:mm:ss"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.string(from: self)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd MM yyyy HH:mm:ss"
        
        if let result = dateFormatter.date(from: dt) {
            return result
        }
        return self
    }
    
    var differenceTimestamp: Int64 {
        return self.timestamp - self.utcTimestamp
    }
    
    var utcTimestamp: Int64 {
        return Int64(utc.timeIntervalSince1970)
    }
    
    var timestamp: Int64 {
        return Int64(timeIntervalSince1970)
    }
    
}

