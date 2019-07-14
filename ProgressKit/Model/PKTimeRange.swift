//
//  PKTimeRange.swift
//  ProgressKit
//
//  Copyright © 2018 ProgressKit authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// Codable time range which is capable of determining lower and upper bounds (start and end dates) of its items.
public enum PKTimeRange: String, Codable {
    /// Time range reflecting the current week.
    case currentWeek
    /// Time range reflecting last week.
    case lastWeek
    /// Time range reflecting the current month.
    case currentMonth
    /// Time range reflecting last month.
    case lastMonth
    /// Time range reflecting the current year.
    case currentYear
    /// Time range reflecting last year.
    case lastYear
    
    /// Iterable object providing all available time ranges.
    public static let availableTimeRanges: [PKTimeRange] = [
        .currentWeek,
        .lastWeek,
        .currentMonth,
        .lastMonth,
        .currentYear,
        .lastYear
    ]
    
    /// Effective start date in a given calendar of the chosen item.
    public func lowerBound(in calendar: Calendar) -> Date {
        let now = Date()
        
        switch self {
        case .currentWeek:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        case .lastWeek:
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekOfYear = (components.weekOfYear ?? 0) - 1
            return calendar.date(from: components)!
        
        case .currentMonth:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        case .lastMonth:
            var components = calendar.dateComponents([.year, .month], from: now)
            components.month = (components.month ?? 0) - 1
            return calendar.date(from: components)!
            
        case .currentYear:
            return calendar.date(from: calendar.dateComponents([.year], from: now))!
        
        case .lastYear:
            var components = calendar.dateComponents([.year], from: now)
            components.year = (components.year ?? 0) - 1
            return calendar.date(from: components)!
        }
    }
    
    /// Effective end date in a given calendar of the chosen item.
    public func upperBound(in calendar: Calendar) -> Date {
        let lowerBound = self.lowerBound(in: calendar)
        
        switch self {
        case .currentWeek, .lastWeek:
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lowerBound)
            components.weekOfYear = (components.weekOfYear ?? 0) + 1
            components.second = -1
            return calendar.date(from: components)!
        
        case .currentMonth, .lastMonth:
            var components = calendar.dateComponents([.year, .month], from: lowerBound)
            components.month = (components.month ?? 0) + 1
            components.second = -1
            return calendar.date(from: components)!
        
        case .currentYear, .lastYear:
            var components = calendar.dateComponents([.year], from: lowerBound)
            components.year = (components.year ?? 0) + 1
            components.second = -1
            return calendar.date(from: components)!
        }
    }
}
