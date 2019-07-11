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

public struct PKReport: Codable {
    public let identifier: String
    
    public let displayStyle: PKDisplayStyle
    public let listIdentifier: String?
    public let searchTerm: String?
    public let isPriorityBased: Bool
    public let timeRange: PKTimeRange?
    public let deadline: Date?
    public let goal: Int?
    public let showInTodayScreen: Bool
    public let notificationsEnabled: Bool?
    
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
