# MGRS iOS

#### Military Grid Reference System Lib ####

The MGRS Library was developed at the [National Geospatial-Intelligence Agency (NGA)](http://www.nga.mil/) in collaboration with [BIT Systems](https://www.caci.com/bit-systems/). The government has "unlimited rights" and is releasing this software to increase the impact of government investments by providing developers with the opportunity to take things in new directions. The software use, modification, and distribution rights are stipulated within the [MIT license](http://choosealicense.com/licenses/mit/).

### Pull Requests ###
If you'd like to contribute to this project, please make a pull request. We'll review the pull request and discuss the changes. All pull request contributions to this project will be released under the MIT license.

Software source code previously released under an open source license and then modified by NGA staff is considered a "joint work" (see 17 USC § 101); it is partially copyrighted, partially public domain, and as a whole is protected by the copyrights of the non-government authors and must be released according to the terms of the original open source license.

### About ###

[MGRS](http://ngageoint.github.io/mgrs-ios/) is a Swift library providing Military Grid Reference System functionality, a geocoordinate standard used by NATO militaries for locating points on Earth.  [MGRS App](https://github.com/ngageoint/mgrs-ios/tree/master/app) is a map implementation utilizing this library.

### Usage ###

View the latest [Appledoc](http://ngageoint.github.io/mgrs-ios/docs/api/)

#### Coordinates ####

```swift

// TODO

```

#### Tile Overlay ####

```swift

// TODO

```

#### Tile Overlay Options ####

```swift

// TODO

```

#### Custom Grids ####

```swift

// TODO

```

#### Draw Tile Template ####

```swift

// TODO

```

### Build ###

[![Build & Test](https://github.com/ngageoint/mgrs-ios/workflows/Build%20&%20Test/badge.svg)](https://github.com/ngageoint/mgrs-ios/actions/workflows/build-test.yml)

Build this repository using Xcode and/or CocoaPods:

    pod install

Open mgrs-ios.xcworkspace in Xcode or build from command line:

    xcodebuild -workspace 'mgrs-ios.xcworkspace' -scheme mgrs-ios build

Run tests from Xcode or from command line:

    xcodebuild test -workspace 'mgrs-ios.xcworkspace' -scheme mgrs-ios -destination 'platform=iOS Simulator,name=iPhone 12'

### Include Library ###

Include this repository by specifying it in a Podfile using a supported option.

Pull from [CocoaPods](https://cocoapods.org/pods/mgrs-ios):

    pod 'mgrs-ios', '~> 1.0.0'

Pull from GitHub:

    pod 'mgrs-ios', :git => 'https://github.com/ngageoint/mgrs-ios.git', :branch => 'master'
    pod 'mgrs-ios', :git => 'https://github.com/ngageoint/mgrs-ios.git', :tag => '1.0.0'

Include as local project:

    pod 'mgrs-ios', :path => '../mgrs-ios'

### Remote Dependencies ###

* [Grid](https://github.com/ngageoint/grid-ios) (The MIT License (MIT)) - Grid Library

### MGRS App ###

The [MGRS App](https://github.com/ngageoint/mgrs-ios/tree/master/app) provides a Military Grid Reference System map using this library.
