# ProgressKit

Swift SDK to visualize your progress based on Apple Reminders.

![ProgressKit Preview](https://github.com/Progress4Apple/ProgressKit/tree/master/ProgressKit.jpg)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See usage for notes on how to use the framework in your own app.

### Prerequisites

- [Xcode 10.2+](https://developer.apple.com/xcode/)
- iOS 12+
- [Swift 5+](https://swift.org/getting-started/)
- [Carthage](https://github.com/Carthage/Carthage#installing-carthage) 
- [Jazzy](https://github.com/realm/jazzy)

### Installing

Simply install the needed dependencies using Carthage to kick things off:

```
carthage bootstrap --platform iOS
```

That's it. Happy Hacking!

## Use in your own app

Simply add ProgressKit as Carthage dependency to use it in your own app. To do so, add the following line to your `Cartfile`:

```
github "Progress4Apple/ProgressKit" ~> 1.0
```

Don't forget to also add the built libraries in Xcode! See ["Adding frameworks to an application" in the Carthage documentation for further details](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application):

- `ProgressKit.framework`
- `FLAnimatedImage.framework`
- `GiphyCoreSDK.framework`

## Built With

* [Giphy](https://github.com/Giphy/giphy-ios-sdk-core/) - The GIPHY Core SDK is a wrapper around the GIPHY API
* [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) - Performant animated GIF engine for iOS
* [Jazzy](https://github.com/realm/jazzy)

## Contributing

Questions and Pull Requests are always welcome. Feel free to submit as you see fit!

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/Progress4Apple/ProgressKit/tags). 

## Authors

* **Marco Betschart** - *Initial work* - [@marbetschar](https://marco.betschart.name)

See also the list of [contributors](https://github.com/Progress4Apple/ProgressKit/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* [Many thanks to the StackOverflow developers pointing out ways on how to detect Emojis in Swift Strings!](https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji)
