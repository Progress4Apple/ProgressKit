# Getting Started

These instructions will get you a up and running to use `ProgressKit` in your own app.

## Prerequisites

Make sure you have the following installed on your system to kick things off:

- [Xcode 10.2+](https://developer.apple.com/xcode/)
- iOS 12+
- [Swift 5+](https://swift.org/getting-started/)
- [Carthage](https://github.com/Carthage/Carthage#installing-carthage) 
- [Jazzy](https://github.com/realm/jazzy)

## Installation

To add `ProgressKit` as Carthage dependency insert the following line to your `Cartfile`:

```
github "Progress4Apple/ProgressKit" ~> 1.0
```

Let `Carthage` download and compile the library by executing the following command:

```
carthage bootstrap --platform iOS
```

As last step add the built libraries in Xcode. See ["Adding frameworks to an application" in the Carthage documentation for further details](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application):

- `ProgressKit.framework`
- `FLAnimatedImage.framework`
- `GiphyCoreSDK.framework`

## Usage

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
