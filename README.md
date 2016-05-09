# Freezer
Freezer is a library that allows your Swift tests to travel through time by mocking `NSDate` class.

## Usage

Once `Freezer.start()` has been invoked, all calls to `NSDate()` or `NSDate(timeIntervalSinceNow: secs)` will return the time that has been frozen.

### Helper function

```swift
freeze(NSDate(timeIntervalSince1970: 946684800)) {
	print(NSDate()) // 2000-01-01 00:00:00 +0000
}
```

### Raw usage

```swift
let freezer = Freezer(to: NSDate(timeIntervalSince1970: 946684800))
freezer.start()
print(NSDate()) // 2000-01-01 00:00:00 +0000
freezer.stop()
```

### Time shifting

Freezer will move you to a specified point in time, but then the time will keep ticking.

```swift
timeshift(NSDate(timeIntervalSince1970: 946684800)) {
	print(NSDate()) // 2000-01-01 00:00:00 +0000
	sleep(2)
	print(NSDate()) // 2000-01-01 00:00:02 +0000
}
```

### Nested calls

Freezer allows performing nested freezing/shifts

```swift
freeze(NSDate(timeIntervalSince1970: 946684800)) {
	freeze(NSDate(timeIntervalSince1970: 946684000)) {
		freeze(NSDate(timeIntervalSince1970: 946684800)) {
			print(NSDate()) // 2000-01-01 00:00:00 +0000
		}
		print(NSDate()) // 1999-12-31 23:46:40 +0000
	}
	print(NSDate()) // 2000-01-01 00:00:00 +0000
}
```

## Installation

### CocoaPods

Just add `pod 'Freezer', '~> 1.0'` to your test target in `Podfile`.

### Carthage

There is no Xcode project, so Carthage will not build a framework for this library. You can still use it, just add `github "Pr0Ger/Freezer" ~> 1.0` to your `Cartfile` and then add `Carthage/Checkout/Freezer/freezer.swift` to your test target.

### Manual

Just copy freezer.swift to your Xcode project and add it to your tests target. Most likely this library will not be updated, unless Apple breaks something by changing an internal implementation of `NSDate`, so this way is good too.

## License

MIT

