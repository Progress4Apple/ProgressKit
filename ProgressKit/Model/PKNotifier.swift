//
//  PKNotifier.swift
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
 `PKNotifier` provides a user notification interface and is capable to decide whether or not `ProgressKit` should inform the user about its progress.
*/
public class PKNotifier: PKNotificationHandler {
    
    /// Shared instance of `PKNotifier`. You'll most probably want to use this except you know otherwise.
    public static let standard = PKNotifier()
    
    /**
     The notification category which is triggered.
     This can be used in your App Extension to decide if the notification needs further processing.
     See `[UNNotificationCategory](https://developer.apple.com/documentation/usernotifications/unnotificationcategory)`.
    */
    enum NotificationCategoryIdentifier: String {
        case giphyNotification = "giphyNotification"
    }
    
    private let baseURL: URL?
    private let userNotificationCenter: UNUserNotificationCenter?
    
    init(suiteName: String? = nil, userNotificationCenter: UNUserNotificationCenter? = nil){
        if let suiteName = suiteName {
            self.baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
        } else {
            self.baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
        
        userNotificationCenter?.setNotificationCategories([
            UNNotificationCategory(
                identifier: NotificationCategoryIdentifier.giphyNotification.rawValue,
                actions: [],
                intentIdentifiers: [],
                hiddenPreviewsBodyPlaceholder: "",
                options: []
            )
        ])
        self.userNotificationCenter = userNotificationCenter
    }
    
    /// Request user authorization in order to be able to send notifications. Uses the userNotificationCenter from `Progress.configure(...)`.
    public func requestAuthorization(completionHandler: @escaping ((Bool, Error?) -> Void)){
        guard let userNotificationCenter = self.userNotificationCenter else {
            completionHandler(false, nil)
            return
        }
        userNotificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: completionHandler)
    }
    
    /// Retrieve the authorizationStatus using the userNotificationCenter from `Progress.configure(...)`.
    public func authorizationStatus(completionHandler: @escaping ((UNAuthorizationStatus) -> Void)){
        guard let userNotificationCenter = self.userNotificationCenter else {
            completionHandler(.notDetermined)
            return
        }
        userNotificationCenter.getNotificationSettings { settings in
            completionHandler(settings.authorizationStatus)
        }
    }
    
    /// Sends all due userNotifications. For this, all reports stored in `PKReportStore` are evaluated against the reminders stored in `PKReminderStore`. You most probably want to call this from a background thread in your app.
    public func sendUserNotificationsWhereNeeded(reportStore: PKReportStore, reminderStore: PKReminderStore, completionHandler: (([PKStatus], [Error]) -> Void)? = nil){
    	purgeSentUserNotifications()
    	
        var allStatus = [PKStatus]()
        var allErrors = [Error]()
        do {
            let dispatchGroup = DispatchGroup()
            
            let reports = try reportStore.loadReports()
            for report in reports {
                guard report.notificationsEnabled ?? false else { continue }
                
                dispatchGroup.enter()
                sendUserNotificationIfNeeded(for: report, of: reminderStore) { status, error in
                    if let error = error {
                        allErrors.append(error)
                    }
                    if let status = status {
                        allStatus.append(status)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.wait()
            
        } catch {
            allErrors.append(error)
        }
        completionHandler?(allStatus, allErrors)
    }

    /// Send due userNotifications for a given report which is evaluated against the reminders stored in `PKReminderStore`. This function is called by `PKNotifier.sendUserNotificationsWhereNeeded(...)`.
    public func sendUserNotificationIfNeeded(for report: PKReport, of reminderStore: PKReminderStore, completionHandler: ((PKStatus?, Error?) -> Void)? = nil) {
        
        guard report.notificationsEnabled ?? false else {
            completionHandler?(nil, nil)
            return
        }
        
        let calendar = Calendar.current
        let nowHour = calendar.component(.hour, from: Date())
        
        // notifications are sent only between 15:00 and 21:00
        guard nowHour > 15, nowHour < 21 else {
            completionHandler?(nil, nil)
            return
        }
        
        reminderStore.fetchStatus(for: report, in: calendar){ [weak self] status, error in
            guard  let status = status, let strongSelf = self else {
                completionHandler?(nil, error)
                return
            }
            
            guard status.goal > 0 else {
            	completionHandler?(nil, nil)
            	return
            }
            
            guard !status.isDone else {
            	let notification = PKUserNotification(
                    reportIdentifier: status.reportIdentifier,
            	    type: .success,
            	    sendAt: Date()
            	)
            			
            	if !strongSelf.hasSent(userNotification: notification) {
                    strongSelf.send(userNotification: notification, for: status) { error in
                        completionHandler?(status, error)
                    }
                
                } else {
                    completionHandler?(status, nil)
                }
            	return
            }
            
            let now = Date()
        	let today = calendar.startOfDay(for: now)
        	var timeRangeStartDate: Date? = nil
        	var timeRangeEndDate: Date? = nil
        	var notificationDate = today
        	
        	if let timeRange = report.timeRange {
        		switch timeRange {
        		case .currentWeek:
        			timeRangeStartDate = strongSelf.startOfWorkWeek(calendar, for: today)
                    if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today) {
                        timeRangeEndDate = strongSelf.startOfWorkWeek(calendar, for: nextWeek)
                    }
        			break
        			
        		case .currentMonth:
        			timeRangeStartDate = strongSelf.startOfMonth(calendar, for: today)
                    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: today) {
                        timeRangeEndDate = strongSelf.startOfMonth(calendar, for: nextMonth)
                    }
                    if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today),
                        let startOfNextWeek = strongSelf.startOfWorkWeek(calendar, for: nextWeek),
                        let endOfCurrentWeek = calendar.date(byAdding: .second, value: -1, to: startOfNextWeek) {
                        notificationDate = endOfCurrentWeek
                    }
        			break
        			
        		case .currentYear:
                    timeRangeStartDate = strongSelf.startOfYear(calendar, for: today)
                    if let nextYear = calendar.date(byAdding: .year, value: 1, to: today) {
                        timeRangeEndDate = strongSelf.startOfYear(calendar, for: nextYear)
                    }
                    
                    if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today),
                        let startOfNextWeek = strongSelf.startOfWorkWeek(calendar, for: nextWeek),
                        let endOfCurrentWeek = calendar.date(byAdding: .second, value: -1, to: startOfNextWeek) {
                        notificationDate = endOfCurrentWeek
                    }
        			break
        		
        		default:
        			break
        		}
        		
            } else if let startDate = status.timeRangeLowerBound, let endDate = report.deadline {
                timeRangeStartDate = startDate
                timeRangeEndDate = endDate
                
                // MARK: determine notificationDate
                let daysUntilDeadline = calendar.dateComponents([.day], from: today, to: endDate).day
                
                // if the deadline is more than one week away, send notification at: endOfCurrentWeek
                if let days = daysUntilDeadline, days >= 7,
                    let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today),
                    let startOfNextWeek = strongSelf.startOfWorkWeek(calendar, for: nextWeek),
                    let endOfCurrentWeek = calendar.date(byAdding: .second, value: -1, to: startOfNextWeek) {
                
                    notificationDate = endOfCurrentWeek
                
                // if the deadline is less than one week away: send notification every day
                } else if let _ = daysUntilDeadline {
                    notificationDate = today
                }
        	}
        	
        	guard let startDate = timeRangeStartDate,
                let endDate = timeRangeEndDate,
                calendar.isDate(today, inSameDayAs: notificationDate) else {
        		completionHandler?(status, nil)
        		return
        	}
        	
        	let totalHoursInTimeRange = endDate.timeIntervalSince(startDate) / 3600
        	let passedHoursOfTimeRange = now.timeIntervalSince(startDate) / 3600
        	let passedTimePercentage = passedHoursOfTimeRange / totalHoursInTimeRange
        	
        	var notificationType: PKUserNotificationType? = nil
        	if passedTimePercentage >= 0.0 {
        		let relativeProgressPercentage = status.completedPercentage - passedTimePercentage
        		
        		// is .behindSchedule? (relativeProgressPercentage less or equal than -5%)
        		if relativeProgressPercentage <= -0.05 {
        			notificationType = .behindSchedule
        					
        		// is .onSchedule? (relativeProgressPercentage greater than -5% and less or equal than +10%)
        		} else if relativeProgressPercentage > -0.05, relativeProgressPercentage <= +0.10 {
        			notificationType = .onSchedule
        			
        		// is .beforeSchedule? (relativeProgressPercentage greater than +10%)
        		} else if relativeProgressPercentage > +0.10 {
        			notificationType = .beforeSchedule
        		}
        	}
            
            guard let type = notificationType else {
                completionHandler?(status, nil)
                return
            }
            
            let notification = PKUserNotification(
                reportIdentifier: status.reportIdentifier,
                type: type,
                sendAt: today
            )
            
            if !strongSelf.hasSent(userNotification: notification){
                strongSelf.send(userNotification: notification, for: status){ error in
                    completionHandler?(status, error)
                }
            
            } else {
                completionHandler?(status, nil)
            }
        }
    }
    
    /// Effectively sends a userNotification for a given `PKStatus`. This method is called by `PKNotifier.sendUserNotificationIfNeeded(...)` if needed.
    func send(userNotification: PKUserNotification, for status: PKStatus, completionHandler: ((Error?) -> Void)? = nil) {
        guard let userNotificationCenter = self.userNotificationCenter else {
            completionHandler?(nil)
            return
        }
        addSent(userNotification: userNotification)
        
        GiphyCore.shared.random(userNotification.randomTerm, media: .gif, rating: .ratedG) { response, error in
            if let error = error {
                print(error)
            }
            
            let gifURLString = response?.data?.images?.downsizedSmall?.gifUrl ??
                response?.data?.images?.fixedHeight?.gifUrl ??
                response?.data?.images?.original?.gifUrl
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = NotificationCategoryIdentifier.giphyNotification.rawValue
            content.title = PKMessageStore.standard.random(for: userNotification.type, key: .title, status.title)
            content.body = PKMessageStore.standard.random(for: userNotification.type, key: .body, status.title)
            content.sound = UNNotificationSound.default
            
            if let urlString = gifURLString, let remoteURL = URL(string: urlString) {
                let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
                let localURL = tempDirURL.appendingPathComponent(userNotification.identifier).appendingPathExtension("gif")
                
                do {
                    let data = try Data(contentsOf: remoteURL)
                    try data.write(to: localURL)
                    let attachment = try UNNotificationAttachment(identifier: "image", url: localURL, options: nil)
                    content.attachments = [ attachment ]
                } catch {
                    print(error)
                }
            }
            
            let notificationRequest = UNNotificationRequest(
                identifier: userNotification.identifier, // needs to be unique for every notification!
                content: content,
                trigger: nil
            )
            
            userNotificationCenter.add(notificationRequest) { error in
                if let error = error {
                    completionHandler?(error)
                    return
                }
                completionHandler?(nil)
            }
        }
    }
    
    
    // MARK: DATE HELPERS
    
    
    /// Get the start of first work day of week for given date
    func startOfWorkWeek(_ calendar: Calendar, for date: Date) -> Date? {
        return calendar.nextWeekend(startingAfter: date, direction: .backward)?.end
    }
    
    /// Get the start of first day in month for a given day
    func startOfMonth(_ calendar: Calendar, for date: Date) -> Date? {
    	let startDateComponents = calendar.dateComponents([.year, .month], from: date)
		if let firstDayOfMonth = calendar.date(from: startDateComponents) {
			return calendar.startOfDay(for: firstDayOfMonth)
		}
    	
    	return nil
    }
    
    /// Get the start of the first day in year for a given day
    func startOfYear(_ calendar: Calendar, for date: Date) -> Date? {
        let startDateComponents = calendar.dateComponents([.year], from: date)
        if let firstDayOfYear = calendar.date(from: startDateComponents) {
            return calendar.startOfDay(for: firstDayOfYear)
        }
        
        return nil
    }
    
    
    // MARK: SENT NOTIFICATIONS HELPERS
    
    private func readSentUserNotifications() -> [PKUserNotification] {
    	guard let fileURL = baseURL?.appendingPathComponent("PKUserNotification").appendingPathExtension("plist"),
            FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
    	do {
        	let decoder = PropertyListDecoder()
            let sentUserNotifications = try decoder.decode([PKUserNotification].self, from: Data(contentsOf: fileURL))
            return sentUserNotifications
        } catch {
        	print(error)
        	return []
        }
    }
    
    @discardableResult
    private func write(sentUserNotifications: [PKUserNotification]) -> Bool {
    	guard let fileURL = baseURL?.appendingPathComponent("PKUserNotification").appendingPathExtension("plist") else {
            return false
        }
    	
    	do {
    		let encoder = PropertyListEncoder()
    		try encoder.encode(sentUserNotifications).write(to: fileURL)
    	
    	} catch {
    		print(error)
    		return false
    	}
    	return true
    }
    
    
    private func hasSent(userNotification: PKUserNotification) -> Bool {
    	let calendar = Calendar.current
        let sentUserNotifications = readSentUserNotifications()
        
        return !sentUserNotifications.isEmpty && sentUserNotifications.contains{
    		return $0.reportIdentifier == userNotification.reportIdentifier &&
    				$0.type == userNotification.type &&
                    calendar.isDate($0.sendAt, inSameDayAs: userNotification.sendAt)
    	}
    }
    
    
    private func addSent(userNotification: PKUserNotification) {
    	var sentUserNotifications = readSentUserNotifications()
    	sentUserNotifications.append(userNotification)
    	write(sentUserNotifications: sentUserNotifications)
    }
    
    
    private func purgeSentUserNotifications() {
    	let fileManager = FileManager.default
    	let calendar = Calendar.current
    	let endOfYesterday = calendar.date(byAdding: .second, value: -1, to: calendar.startOfDay(for: Date()))
    	
    	let oldValue = readSentUserNotifications()
    	var newValue = [PKUserNotification]()
    	for notification in oldValue {
    		guard let endDate = endOfYesterday, notification.sendAt < endDate else {
    			newValue.append(notification)
    			continue
    		}
			
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(notification.identifier).appendingPathExtension("gif")
            if fileManager.fileExists(atPath: fileURL.path) {
            	do {
            		try fileManager.removeItem(atPath: fileURL.path)
            	} catch {
            		print(error)
            	}
            }
    	}
    	write(sentUserNotifications: newValue)
    }
}
