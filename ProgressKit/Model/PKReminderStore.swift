//
//  PKReminderStore.swift
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

import EventKit

/**
 Convenience interface for interacting with [Apples EventKit framework](https://developer.apple.com/documentation/eventkit).
 */
public class PKReminderStore: PKNotificationHandler {
    
    /// Shared instance of `PKReminderStore`. You'll most probably want to use this instead of creating your own instance.
    public static let standard = PKReminderStore(eventStore: EKEventStore())
    
    private let eventStore: EKEventStore
    init(eventStore: EKEventStore) {
        self.eventStore = eventStore
        NotificationCenter.default.addObserver(self, selector: #selector(eventStoreDidChange), name: .EKEventStoreChanged, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func eventStoreDidChange(){
        post(notification: .reminderStoreDidChange)
    }
    
    /// Retrieves all Apple Reminder Lists as [`EKCalendar` objects](https://developer.apple.com/documentation/eventkit/ekcalendar).
    public func allLists(completionHandler: @escaping (([EKCalendar]?, Error?) -> Void )) {
        verifyAuthorization(to: eventStore) { [weak self] status, error in
            guard status == .authorized, let strongSelf = self else {
                completionHandler(nil, error)
                return
            }
            completionHandler(strongSelf.eventStore.calendars(for: .reminder), nil)
        }
    }
    
    /// Verifies user authorization for access to the [`EKEventStore`](https://developer.apple.com/documentation/eventkit/ekeventstore).
    public func verifyAuthorization(completionHandler: @escaping ((EKAuthorizationStatus?, Error?) -> Void)) {
        verifyAuthorization(to: eventStore, completionHandler: completionHandler)
    }
    
    private func verifyAuthorization(to eventStore: EKEventStore, completionHandler: @escaping ((EKAuthorizationStatus?, Error?) -> Void)) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        
        if status == .notDetermined {
            eventStore.requestAccess(to: .reminder){ accessGranted, error in
                if let error = error {
                    completionHandler(nil, error)
                    
                } else if accessGranted != true {
                    completionHandler(.denied, nil)
                    
                } else {
                    completionHandler(.authorized, nil)
                }
            }
            
        } else {
            completionHandler(status, nil)
        }
    }
    
    /// Fetches the progress status for a given `PKReport` using a provided [`Calendar`](https://developer.apple.com/documentation/foundation/calendar).
    public func fetchStatus(for report: PKReport, in calendar: Calendar, completionHandler: @escaping ((PKStatus?, Error?)->Void)) {
        allLists { [weak self] allLists, error in
            guard error == nil, let strongSelf = self else {
                completionHandler(nil, error)
                return
            }
            var status = PKStatus(for: report)
            
            var lists: [EKCalendar]? = nil
            var removeAllWhereNotContainsSearchTerm : ((EKReminder) -> Bool)? = nil
            
            if let searchTerm = report.searchTerm, !searchTerm.isEmpty {
                status.title = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let searchTermLowerCased = status.title.lowercased()
                removeAllWhereNotContainsSearchTerm = {
                    return false == $0.title?.lowercased().contains(searchTermLowerCased)
                }
                
            } else if let listIdentifier = report.listIdentifier, let allLists = allLists {
                lists = allLists.reduce(nil){
                    if $1.calendarIdentifier == listIdentifier {
                        return [$1]
                    }
                    return $0
                }
                
                if let list = lists?.first {
                    status.title = list.title
                    status.tintColor = list.cgColor
                }
            }
            
            if status.title.isEmpty {
                status.title = NSLocalizedString("Overall", comment: "overall").localizedCapitalized
            }
            status.timeRangeLowerBound = report.timeRange?.lowerBound(in: calendar)
            status.timeRangeUpperBound = report.timeRange?.upperBound(in: calendar)
            
            if status.timeRangeLowerBound == nil, status.timeRangeUpperBound == nil {
                let allPredicate = strongSelf.eventStore.predicateForReminders(in: lists)
                
                strongSelf.eventStore.fetchReminders(matching: allPredicate){ allReminders in
                    var allReminders = allReminders ?? []
                    if let notContainsSearchTerm = removeAllWhereNotContainsSearchTerm {
                        allReminders.removeAll(where: notContainsSearchTerm)
                    }
                    
                    status.goal = report.goal ?? 0
                    status.completed = 0
                    
                    for reminder in allReminders {
                        let score = report.score(for: reminder)
                        
                        if report.goal == nil {
                            status.goal += score
                        }
                        
                        if reminder.isCompleted {
                            status.completed += score
                        }
                        
                        if let creationDate = reminder.creationDate {
                            
                            if let timeRangeLowerBound = status.timeRangeLowerBound,
                                creationDate.timeIntervalSince(timeRangeLowerBound) < 0 {
                                status.timeRangeLowerBound = creationDate
                                
                            } else if status.timeRangeLowerBound == nil {
                                status.timeRangeLowerBound = creationDate
                            }
                        }
                        
                        if let dueDateComponents = reminder.dueDateComponents,
                            let dueDate = calendar.date(from: dueDateComponents) {
                            
                            if let timeRangeUpperBound = status.timeRangeUpperBound,
                                dueDate.timeIntervalSince(timeRangeUpperBound) > 0 {
                                status.timeRangeUpperBound = dueDate
                            
                            } else if status.timeRangeUpperBound == nil{
                                status.timeRangeUpperBound = dueDate
                            }
                        }
                    }
                    
                    if let deadline = report.deadline {
                        status.timeRangeUpperBound = deadline
                    }
                    completionHandler(status, nil)
                }
                
            } else {
                let completedPredicate = strongSelf.eventStore.predicateForCompletedReminders(
                    withCompletionDateStarting: status.timeRangeLowerBound,
                    ending: status.timeRangeUpperBound,
                    calendars: lists)
                
                strongSelf.eventStore.fetchReminders(matching: completedPredicate){ [weak self] allCompleted in
                    var remindersCompleted = allCompleted ?? []
                    if let notContainsSearchTerm = removeAllWhereNotContainsSearchTerm {
                        remindersCompleted.removeAll(where: notContainsSearchTerm)
                    }
                    status.completed = remindersCompleted.reduce(0){ $0 + report.score(for: $1) }
                    
                    if let goal = report.goal {
                        status.goal = goal
                        completionHandler(status, nil)
                        
                    } else {
                        guard let strongSelf = self else {
                            completionHandler(status, nil)
                            return
                        }
                        
                        let inCompletePredicate = strongSelf.eventStore.predicateForIncompleteReminders(
                            withDueDateStarting: status.timeRangeLowerBound,
                            ending: status.timeRangeUpperBound,
                            calendars: lists)
                        
                        strongSelf.eventStore.fetchReminders(matching: inCompletePredicate){ allInComplete in
                            var remindersInComplete = allInComplete ?? []
                            if let notContainsSearchTerm = removeAllWhereNotContainsSearchTerm {
                                remindersInComplete.removeAll(where: notContainsSearchTerm)
                            }
                            status.goal = status.completed + remindersInComplete.reduce(0){ $0 + report.score(for: $1) }
                            completionHandler(status, nil)
                        }
                    }
                }
            }
        }
    }
}
