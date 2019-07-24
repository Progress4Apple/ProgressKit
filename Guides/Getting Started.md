# Getting Started

These instructions will get you a up and running to use `ProgressKit` in your own app.

## Installation

See the Getting Started section of the README for how to install `ProgressKit`.

## Configuration

Import `ProgressKit` and call `Progress.configure(...)` in `application(_:didFinishLaunchingWithOptions:)` of your AppDelegate.swift for initialization:

```
import UserNotifications
import ProgressKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {

    Progress.configure(
        suiteName: "group.suite-name",
        userNotificationCenter: UNUserNotificationCenter.current(),
        giphyApiKey: "your-giphy-api-key"
    )
```

## Create a ViewController

To render the progress bars for the available reports, create a new `UICollectionViewController` in your app and subclass the `ProgressCollectionViewController`:

```
import UIKit
import ProgressKit

class ViewController: ProgressCollectionViewController {
    ...
}
````

## Set delegate and dataSource

Make sure you set the ViewController's delegate and dataSource objects In your `viewDidLoad`. To begin with, we set both to `self`:

```
import UIKit
import ProgressKit

class ViewController: ProgressCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
    }
}
```

Then we make sure our ViewController conforms to `ProgressCollectionViewControllerDelegate`:

```
import UIKit
import ProgressKit
import EventKit

class ViewController: ProgressCollectionViewController, ProgressCollectionViewControllerDelegate {
    ...
    
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
}
```

... and finally, our ViewController should also conform to `ProgressCollectionViewControllerDataSource`:

```
import UIKit
import ProgressKit
import EventKit

class ViewController: ProgressCollectionViewController, ProgressCollectionViewControllerDelegate, ProgressCollectionViewControllerDataSource {
    ...

    // MARK: ProgressCollectionViewControllerDataSource

    func progressCollection(
        _ viewController: ProgressCollectionViewController,
        loadReports completionHandler: ([[PKReport]]?, Error?) -> Void
    ) {
        let report = PKReport(
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
        let reportSection = [report]
        
        var allReports = [[PKReport]]()
        allReports.append(reportSection)
        
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
```

## Next steps

There you go. That's the bare minimum you need to render reports. As next step you may want to add your implementation for saving and loading reports so the user is able to configure those. For this have a look at `PKReportStore.standard` which makes it easy to persist and query reports to/from disk.
