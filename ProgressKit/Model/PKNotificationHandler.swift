//
//  PKNotificationHandler.swift
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

/// Generic protocol which adds basic NotificationHandler capabilities to its conforming objects.
public protocol PKNotificationHandler {}

extension PKNotificationHandler {
    
    func post(notification: PKNotification) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notification.rawValue)))
    }
    
    /// Adds an observer for all given `PKNotification`s and returns a `PKNotification.Token`.
    public func addObserver(for notifications: [PKNotification], queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) -> [PKNotification.Token] {
        
        return notifications.map{ notification in
            return self.addObserver(for: notification, queue: queue, using: block)
        }
    }
    
    /// Add an observer for a given `PKNotification` and return a `PKNotification.Token`.
    public func addObserver(for notification: PKNotification, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) -> PKNotification.Token {
        
        let notificationCenter = NotificationCenter.default
        let rawToken = notificationCenter.addObserver(forName: Notification.Name(notification.rawValue), object: nil, queue: queue, using: block)
        
        return PKNotification.Token(notificationCenter: notificationCenter, token: rawToken)
    }
    
    /// Remove an observer by its `PKNotification.Token`.
    public func removeObserver(token: PKNotification.Token) {
        guard let rawToken = token.rawToken else { return }
        token.notificationCenter?.removeObserver(rawToken)
    }
}
