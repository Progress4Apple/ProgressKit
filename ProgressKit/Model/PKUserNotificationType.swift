//
//  PKUserNotificationType.swift
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

/// Type of notification the user should receive. The tone reflects their current progress towards the predefined reports.
enum PKUserNotificationType: String, Codable {
    
    /// The user is behind schedule and should speed up to achieve their defined goal.
    case behindSchedule = "behindSchedule"
    
    /// The user is on schedule and should keep on to achieve their defined goal.
    case onSchedule = "onSchedule"
    
    /// The user is before schedule and should achieve their defined goal easily.
    case beforeSchedule = "beforeSchedule"
    
    /// The user achieved their defined goal.
    case success = "success"
    
    /// Retrieves predefined keywords depending on the chosen `PKUserNotificationType`.
    static func availableTerms(for notificationType: PKUserNotificationType) -> [String] {
        switch notificationType {
        case .behindSchedule:
            return ["lazy", "epic+fail"]
            
        case .onSchedule:
            return ["okay"]
            
        case .beforeSchedule:
            return ["good job"]
            
        case .success:
            return ["celebrate", "like a boss"]
        }
    }
}
