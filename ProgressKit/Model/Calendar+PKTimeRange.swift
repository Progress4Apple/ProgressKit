//
//  Calendar+PKTimeRange.swift
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

extension Calendar {
    
    public func string(from timeRange: PKTimeRange) -> String?{
        let formatter = DateFormatter()
        let now = Date()
        
        switch timeRange {
        case .currentWeek:
            return [
                NSLocalizedString("CW", comment: "Calendar Week Short Notation"),
                String(component(.weekOfYear, from: now))
            ].joined(separator: " ")

        case .lastWeek:
            return [
                NSLocalizedString("CW", comment: "Calendar Week Short Notation"),
                String(component(.weekOfYear, from: date(byAdding: .weekOfYear, value: -1, to: now)!))
            ].joined(separator: " ")
        
        case .currentMonth:
            formatter.dateFormat = "MMMM"
            return formatter.string(from: now)
            
        case .lastMonth:
            formatter.dateFormat = "MMMM"
            return formatter.string(from: date(byAdding: .month, value: -1, to: now)!)
            
        case .currentYear:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: now)
        
        case .lastYear:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: date(byAdding: .year, value: -1, to: now)!)
        }
    }
}
