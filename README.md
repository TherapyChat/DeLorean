<p align="center"><img width="600" src="./resources/logo.svg"></p>

![build](https://img.shields.io/travis/TherapyChat/DeLorean.svg)
![swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-333333.svg)
![cocoapods](https://img.shields.io/cocoapods/v/DeLorean.svg)
![carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)
![coverage](https://img.shields.io/codecov/c/github/TherapyChat/DeLorean.svg)
![license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)

## Table of Contents
* [Overview](#overview)
* [Features](#features)
* [Getting Started](#getting-started)
* [Basics](#basics)
    * [Creating promises](#creating-promises)
    * [Then](#then)
    * [Catch](#catch)
    * [Progress](#progress)
    * [Cancel](#cancel)
* [Extensions](#extensions) 
    * [All](#all)
    * [Always](#always)
    * [Race](#race)
    * [Recover](#recover)
    * [Retry](#retry)
    * [Timeout](#timeout)
    * [Validate](#validate)
    * [Zip](#zip)
* [Installation](#installation)
    * [CocoaPods](#cocoapods)
    * [Carthage](#carthage)
    * [Swift Package Manager](#swift-package-manager)
* [Author](#author)
* [Contribution](#contribution)
* [License](#license)
* [Changelog](#changelog)

## Overview
DeLorean is a lightweight framework which allows you to write better async code in Swift. We designed DeLorean to be simple to use and also very flexible. It's partially based on [JavaScript A+](https://promisesaplus.com) specs. We have added some useful features like `progressable` and `cancellable` promises. This promises layer queues all async task on background to avoid block the main thread.

## Features
- Super friendly API
- Enum-based DSL to handle Promise state
- Promises can be dispatched on any thread or custom queue
- All promises are `Cancellable` and `progressable`
- The framework has 100% test coverage
- No external dependencies
- Minimal implementation
- Support for `iOS/macOS/tvOS/watchOS`
- Support for CocoaPods/Carthage/Swift Package Manager

## Getting Started

This is a tiny example to build and execute a promise with `DeLorean`.

```swift
let foobar = Promise { future in
    future(.fulfill("foobar"))
}

foobar.then { value in
    print(value)
}
```

## Basics

### Creating promises

You can create and Promise with enum DSL for `async` operations. 

```swift
let foobar = Promise { future in 
    future(.progress("foo"))
    future(.fulfill("foobar"))
}

foobar.progress {
    print($0)
}.then { string in
    print(string)
}
```

Also, you can create and Promise with block API for `async` operations.

```swift
let foobar = Promise { progress, fulfill, reject, cancel in 
    progress("foo")
    cancel()
}

foobar.progress {
    print($0)
}.cancel { 
    // ¯\_(ツ)_/¯
}
```

### Then

You can simple chaining multiple asynchronous tasks.

```swift
let foobar = Promise { future in 
    future(.fulfill("foobar"))
}

promise.then { value in 
    print(value)
}
```

Or you can transform data between chainable promises.

```swift
let foobar = Promise { future in 
    future(.fulfill("foobar"))
}.then({ value in 
    print(value)
}).then({ value in 
    return value.count
}).then({ value in 
    return value > 0
})
```

### Catch

This function allows you to handle Promise's errors. The operator itself implicitly returns another promise, that is rejected with the same error.

```swift
let foobar = Promise<Void> { future in 
    future(.reject(SimpleError()))
}.then({ value in 
    print(value)
}).catch({ error in 
    // Handle simple error here
})
```

### Progress  

If there is an asynchronous action that can "succeed" more than once, or delivers a series of values over time instead of just one, but you don't want to finish the promise you can use this function.

```swift
let foobar = Promise<Int> { future in 
    future(.progress(0))
    future(.progress(1))
    future(.progress(2))
    future(.fulfill(3))
}.progress({ value in 
    // This block is called multiple times
    print(value)
}).then({ value in 
    // This block is called once
    print(value)
})
```

### Cancel

This function will trigger a callback that the promise can use to cancel its work. Naturally, requesting cancellation of a promise that has already been resolved does nothing, even if the callbacks have not yet been invoked.

```swift
let foobar = Promise<Int> { future in 
    future(.progress(0))
    future(.cancel)
    future(.fulfill(3))
}.progress { 
    print($0)
}.cancel {
    // Handle cancellable work
}.then { value in 
    // This block is never called
    print(value)
}
```

## Extensions

### All

This function create a Promise that resolved when the list of passed Promises resolves (promises are resolved in parallel). Promise also reject as soon as a promise reject for any reason.

```swift
let promise1 = Promise(value: 1)
let promise2 = Promise(value: 2)
let promise3 = Promise(value: 3)
let promise4 = Promise(value: 4)

let promise = Promise<Int>
    .all([promise1, promise2, promise3, promise4])
    .then { values in 
        for number in values {
            print(number)
        }
    }
```

### Always

This function allows you to specify a block which will be always executed both for fulfill and reject of the Promise.

```swift
let foobar = Promise<Int> { _ in 
    throw SimpleError()
}.then { 
    print($0)
}.catch {
    // Handle error
}.always {
    // This block is always called
}
```

### Race 
This function race many asynchronous promises and return the value of the first to complete.

```swift
let promise1 = Promise(value: 1)
let promise2 = Promise(value: 2)
let promise3 = Promise(value: 3)
let promise4 = Promise(value: 4)

let promise = Promise<Int>
    .race([promise1, promise2, promise3, promise4])
    .then { fastValue in 
        print(fastValue)
    }
```

### Recover 

Recover lets us catch an error and easily recover from it without breaking the rest of the promise chain.

```swift
let foobar = Promise<Int> { _ in 
    throw SimpleError()
}.recover { error in
    return Promise(value: 0)
}.then {
    print($0)
}.catch {
    // Handle error
}
```

### Retry 

Retry operator allows you to execute source chained promise if it ends with a rejection. If reached the attempts the promise still rejected chained promise is also rejected along with the same source error.

```swift 
let promise = Promise<Int>
    .retry(attempt: 3) { () -> Promise<Int> in
        guard threshold != 1 else { return Promise(value: 8) }
        threshold -= 1
        return Promise(error: SimpleError())
}
```

### Timeout

Timeout allows us to wait for a promise for a time interval or reject it, if it doesn't resolve within the given time. The interval is expresed in seconds. 

```swift
let promise = Promise<Int> { future in
    future(.fulfill(5))
}.timeout(0.5)
```

### Validate

Validate is a function that takes a predicate, and rejects the promise chain if that predicate fails.

```swift
let promise = Promise(value: 2)
    .validate { $0 == 3 }
    .catch { error in 
        // This promise always fails 
    }
```

### Zip 

This function allows you to join different promises (2, 3 or 4) and return a tuple with the result of them. Promises are resolved in parallel.

```swift
let promise1 = Promise(value: 0)
let promise2 = Promise(value: "foobar")
let zipped = Promise<Void>.zip(promise1, promise2)
    .then { value1, value2 in
        print(value1) // This function prints `0` 
        print(value2) // This function prints `"foobar"`
}
```

You can check the `DeLorean.playground` to experiment with more examples. If you need to see deeply information you can check our [Documentation](https://therapychat.github.io/DeLorean/)

## Installation

### CocoaPods

DeLorean is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, '10.0'
use_frameworks!
swift_version = '4.0'

target 'MyApp' do
  pod 'DeLorean'
end
```
### Carthage

You can also install it via [Carthage](https://github.com/Carthage/Carthage). To do so, add the following to your Cartfile:

```swift
github 'therapychat/DeLorean'
```

### Swift Package Manager

You can use [Swift Package Manager](https://swift.org/package-manager/) and specify dependency in `Package.swift` by adding this:
```swift
.Package(url: "https://github.com/therapychat/DeLorean.git", majorVersion: 0)
```

## Author

Sergio Fernández, fdz.sergio@gmail.com

## Contribution

For the latest version, please check [develop](https://github.com/therapychat/DeLorean/tree/develop) branch. Changes from this branch will be merged into the [master](https://github.com/therapychat/DeLorean/tree/master) branch at some point.

- If you want to contribute, submit a [pull request](https://github.com/therapychat/DeLorean/pulls) against a development `develop` branch.
- If you found a bug, [open an issue](https://github.com/therapychat/DeLorean/issues).
- If you have a feature request, [open an issue](https://github.com/therapychat/DeLorean/issues).

## License

DeLorean is available under the `Apache License 2.0`. See the [LICENSE](./LICENSE) file for more info.


## Changelog

See [CHANGELOG](./CHANGELOG) file.