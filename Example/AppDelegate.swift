//
//  AppDelegate.swift
//  Example
//
//  Created by Marco Betschart on 10.09.19.
//  Copyright © 2019 Progress for Apple Reminders. All rights reserved.
//

import UIKit
import UserNotifications
import ProgressKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Progress.configure(
            suiteName: "group.suite-name",
            userNotificationCenter: UNUserNotificationCenter.current(),
            giphyApiKey: "your-giphy-api-key"
        )
        return true
    }
}
