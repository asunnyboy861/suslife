//
//  Date+Extensions.swift
//  suslife
//
//  Date helper extensions
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    func daysSince(_ earlierDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: earlierDate, to: self).day ?? 0
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    func formatted(with formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
    
    var displayFormat: String {
        DateFormatter.suslifeDisplay.string(from: self)
    }
    
    var monthYearFormat: String {
        DateFormatter.suslifeMonthYear.string(from: self)
    }
    
    var dayOfWeek: String {
        DateFormatter.suslifeDayOfWeek.string(from: self)
    }
}
