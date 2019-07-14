//
//  Progress.swift
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
import UserNotifications
import GiphyCoreSDK

/**
 `Progress` is a convenient interface for reminders & reports and it's the primary means of interacting with them.
*/
public class Progress {
    
    /// The shared report manager which provides access to report CRUD operations.
    public static private (set) var reportStore = PKReportStore.standard
    
    /// The shared reminder manager which provides access to Apple Reminders.
    public static private (set) var reminderStore = PKReminderStore.standard
    
    /// The shared notifier manager which handles user notification handling.
    public static private (set) var notifier = PKNotifier.standard
    
    /**
     Configuration method which initializes the ProgressKit framework for usage in your own app.
     
     - parameter suiteName: A string that names the group whose shared directory you want to obtain. This input should exactly match one of the strings in the app's [App Groups Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups).
     - parameter userNotificationCenter: The central object for managing notification-related activities for your app or app extension. Usually you just want to use `UNUserNotificationCenter.current()`.
     - parameter giphyApiKey: A string containing the Giphy Api Key to use. See [Request A GIPHY API Key](https://support.giphy.com/hc/en-us/articles/360020283431-Request-A-GIPHY-API-Key) to obtain one.
    */
    public static func configure(
        suiteName: String? = nil,
        userNotificationCenter: UNUserNotificationCenter? = nil,
        giphyApiKey: String = ""
    ) {
        Progress.reportStore = PKReportStore(suiteName: suiteName)
        Progress.notifier = PKNotifier(suiteName: suiteName, userNotificationCenter: userNotificationCenter)
        GiphyCore.configure(apiKey: giphyApiKey)
    }
}
