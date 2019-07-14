//
//  PKReport.swift
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
import EventKit

/**
 A user defined report which is the heart of any progress calculation.
 A `PKReport` declares which goal the user want to achieve within a `PKTimeRange`.
 */
public struct PKReport: Codable {
    
    /// Unique identifier of `PKReport`.
    public let identifier: String
    
    /// Defines how the `PKReport` should be rendered. Either a bar which shows the current progres, or a bar which shows the remaining amount of work.
    public let displayStyle: PKDisplayStyle
    
    /// Unique identifier of an Apple Reminder list. See [`EKCalendar.calendarIdentifier`](https://developer.apple.com/documentation/eventkit/ekcalendar/1507380-calendaridentifier).
    public let listIdentifier: String?
    
    /// A search term which should be used to match Apple Reminders against this `PKReport`. IMPORTANT: The text needs to be part of the reminders title.
    public let searchTerm: String?
    
    /// Whether or not to calculate the progress of this `PKReport` based upon Apple Reminder priorities.
    public let isPriorityBased: Bool
    
    /// The time range in which the desired goal should be achieved. If `nil` the `overall` time range is used.
    public let timeRange: PKTimeRange?
    
    /// Deadline of this report if any.
    public let deadline: Date?
    
    /// The desired goal, the user wants to achieve. If `nil` the desired goal is to complete all matched Apple Reminders.
    public let goal: Int?
    
    /// If this `PKReport` should be rendered in the Today Screen Widget.
    public let showInTodayScreen: Bool
    
    /// Whether or not the user wants to receive notifications regarding this report.
    public let notificationsEnabled: Bool?
    
    /// Convenience constructor which initializes all properties.
    public init(
        identifier: String,
        displayStyle: PKDisplayStyle,
        listIdentifier: String?,
        searchTerm: String?,
        isPriorityBased: Bool,
        timeRange: PKTimeRange?,
        deadline: Date?,
        goal: Int?,
        showInTodayScreen: Bool,
        notificationsEnabled: Bool?
    ){
        self.identifier = identifier
        self.displayStyle           = displayStyle
        self.listIdentifier         = listIdentifier
        self.searchTerm             = searchTerm
        self.isPriorityBased        = isPriorityBased
        self.timeRange              = timeRange
        self.deadline               = deadline
        self.goal                   = goal
        self.showInTodayScreen      = showInTodayScreen
        self.notificationsEnabled   = notificationsEnabled
    }
    
    /// Calculates the score for a given `EKReminder` based upon the `isPriortiyBased` flag.
    func score(for reminder: EKReminder) -> Int {
        if isPriorityBased {
            switch reminder.priority {
            case Int(EKReminderPriority.high.rawValue): return 5
            case Int(EKReminderPriority.medium.rawValue): return 3
            case Int(EKReminderPriority.low.rawValue): return 1
            default: return 0
            }
        }
        return 1
    }
}


extension PKReport: Hashable {
    
    /// Makes `PKReport` conforming to the [`Hashable` protocol](https://developer.apple.com/documentation/swift/hashable).
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
