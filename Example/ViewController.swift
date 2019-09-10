//
//  ViewController.swift
//  Example
//
//  Created by Marco Betschart on 10.09.19.
//  Copyright © 2019 Progress for Apple Reminders. All rights reserved.
//

import UIKit
import ProgressKit
import EventKit

class ViewController: ProgressCollectionViewController,
ProgressCollectionViewControllerDelegate,
ProgressCollectionViewControllerDataSource {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
    }
    
    
    // MARK: ProgressCollectionViewControllerDelegate

    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        handleAuthorizationStatusNotSufficient status: EKAuthorizationStatus
    ) {
    // TODO: Insert your implementation here.
    }


    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        didSelectReport report: PKReport
    ) {
        // TODO: Insert your implementation here.
    }


    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        handleError error: Error
    ) {
        // TODO: Insert your implementation here.
    }


    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        openPreferencesAtURL url: URL,
        completionHandler: @escaping ((Bool) -> Void)
    ) {
        UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
    }
    
    
    // MARK: ProgressCollectionViewControllerDataSource

    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        loadReports completionHandler: ([[PKReport]]?, Error?) -> Void
    ) {
        let report1 = PKReport(
            identifier: "1234",
            displayStyle: .progress,
            listIdentifier: nil,
            searchTerm: nil,
            isPriorityBased: false,
            timeRange: nil,
            deadline: nil,
            goal: nil,
            showInTodayScreen: false,
            notificationsEnabled: false
        )
        let report2 = PKReport(
            identifier: "5678",
            displayStyle: .progress,
            listIdentifier: nil,
            searchTerm: nil,
            isPriorityBased: false,
            timeRange: nil,
            deadline: nil,
            goal: nil,
            showInTodayScreen: false,
            notificationsEnabled: false
        )
        let report3 = PKReport(
            identifier: "90123",
            displayStyle: .progress,
            listIdentifier: nil,
            searchTerm: nil,
            isPriorityBased: false,
            timeRange: nil,
            deadline: nil,
            goal: nil,
            showInTodayScreen: false,
            notificationsEnabled: false
        )
        let report4 = PKReport(
            identifier: "4567",
            displayStyle: .progress,
            listIdentifier: nil,
            searchTerm: nil,
            isPriorityBased: false,
            timeRange: nil,
            deadline: nil,
            goal: nil,
            showInTodayScreen: false,
            notificationsEnabled: false
        )
        let report5 = PKReport(
            identifier: "89012",
            displayStyle: .remaining,
            listIdentifier: nil,
            searchTerm: nil,
            isPriorityBased: false,
            timeRange: nil,
            deadline: nil,
            goal: nil,
            showInTodayScreen: false,
            notificationsEnabled: false
        )
        let reportSection1 = [report1, report2, report3, report4]
        let reportSection2 = [report5]

        var allReports = [[PKReport]]()
        allReports.append(reportSection1)
        allReports.append(reportSection2)

        completionHandler(allReports, nil)
    }


    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        shouldReload completionHandler: ((Bool) -> Void)
    ) {
        completionHandler(true)
    }


    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        saveReports reports: [[PKReport]],
        completionHandler: ((Bool, Error?) -> Void)
    ) {
        // TODO: Insert your implementation here.
    }
}
