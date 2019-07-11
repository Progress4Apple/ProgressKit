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

public struct PKStatus {
    public let reportIdentifier: String
    
    init(for report: PKReport){
        reportIdentifier = report.identifier
    }
    
    public var title: String = ""
    public var tintColor: CGColor? = nil
    public var goal: Int = 1
    public var completed: Int = 0
    
    public var timeRangeLowerBound: Date? = nil
    public var timeRangeUpperBound: Date? = nil
    
    public var completedPercentage: Double {
        guard goal > 0 else { return 1.0 }
        return Double(completed) / Double(goal)
    }
    
    public var remainingPercentage: Double {
        return 1.0 - completedPercentage
    }
    
    public var remaining: Int {
        return goal - completed
    }
    
    public var isDone: Bool {
        return completedPercentage >= 1.0
    }
}

extension PKStatus: Equatable {
    static public func == (lhs: PKStatus, rhs: PKStatus) -> Bool {
        return lhs.reportIdentifier == rhs.reportIdentifier &&
            lhs.title == rhs.title &&
            lhs.tintColor == rhs.tintColor &&
            lhs.goal == rhs.goal &&
            lhs.completed == rhs.completed
    }
}
