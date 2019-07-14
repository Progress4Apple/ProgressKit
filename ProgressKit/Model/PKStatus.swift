//
//  PKStatus.swift
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

/**
 Provides an evaluated progress status of a given report.
 */
public struct PKStatus {
    /// Unique identifier of a `PKReport.identifier`
    public let reportIdentifier: String
    
    /// Constructor to build a new `PKStatus`.
    init(for report: PKReport){
        reportIdentifier = report.identifier
    }
    
    /// Title of `PKStatus`
    public var title: String = ""
    
    /// Tint color of `PKStatus` if any. This reflects the color of a given Apple Reminder list if any.
    public var tintColor: CGColor? = nil
    
    /// The user defined goal to achieve.
    public var goal: Int = 1
    
    /// Reflects how many points the user already achieved.
    public var completed: Int = 0
    
    /// The start date of the user defined `PKReport.timeRange`
    public var timeRangeLowerBound: Date? = nil
    
    /// The end date of the user defined `PKReport.timeRange`
    public var timeRangeUpperBound: Date? = nil
    
    /// The progress as percentage.
    public var completedPercentage: Double {
        guard goal > 0 else { return 1.0 }
        return Double(completed) / Double(goal)
    }
    
    /// The remaining percentage.
    public var remainingPercentage: Double {
        return 1.0 - completedPercentage
    }
    
    /// The remaining points as fixed value.
    public var remaining: Int {
        return goal - completed
    }
    
    /// Flag whether the user already achieved their goal.
    public var isDone: Bool {
        return completedPercentage >= 1.0
    }
}


extension PKStatus: Equatable {
    
    /// Makes `PKStatus` conform to the [`Equatable` protocol](https://developer.apple.com/documentation/swift/equatable).
    static public func == (lhs: PKStatus, rhs: PKStatus) -> Bool {
        return lhs.reportIdentifier == rhs.reportIdentifier &&
            lhs.title == rhs.title &&
            lhs.tintColor == rhs.tintColor &&
            lhs.goal == rhs.goal &&
            lhs.completed == rhs.completed
    }
}
