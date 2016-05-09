//
// Created by Sergey on 07/05/16.
//

import Foundation

@available(iOS, deprecated=10.0)
func _Selector(str: String) -> Selector {
    // Now Xcode can fuck off with his suggestion to use #selector
    return Selector(str)
}

enum StartingPoint: Equatable {
    case Fixed(NSDate)
    case Offset(NSTimeInterval)
}

func == (lhs: StartingPoint, rhs: StartingPoint) -> Bool {
    switch (lhs, rhs) {
    case (.Fixed(let lvalue), .Fixed(let rvalue)) where lvalue == rvalue: return true
    case (.Offset(let lvalue), .Offset(let rvalue)) where lvalue == rvalue: return true
    default: return false
    }
}

extension NSDate {
    func newInit() -> NSDate {
        return now()
    }

    func newInitWithTimeIntervalSinceNow(timeIntervalSinceNow secs: NSTimeInterval) -> NSDate {
        return NSDate(timeInterval: secs, sinceDate: now())
    }

    convenience init(timeIntervalSinceRealNow secs: NSTimeInterval) {
        // After we swizzle initWithTimeIntervalSinceNow: this method is only way to obtain real date
        self.init(timeIntervalSinceNow: secs)
    }

    private func now() -> NSDate {
        let startingPoint = Freezer.startingPoints.last!
        switch startingPoint {
        case .Fixed(let date): return date
        case .Offset(let interval): return NSDate(timeIntervalSinceRealNow: interval)
        }
    }
}

public class Freezer {
    private static var oldNSDateInit: IMP!
    private static var oldNSDateInitWithTimeIntervalSinceNow: IMP!

    private static var startingPoints: [StartingPoint] = []

    let startingPoint: StartingPoint

    private(set) var running: Bool = false

    init(to: NSDate) {
        self.startingPoint = .Fixed(to)
    }

    init(from: NSDate) {
        let now = NSDate(timeIntervalSinceRealNow: 0)
        self.startingPoint = .Offset(from.timeIntervalSince1970 - now.timeIntervalSince1970)
    }

    deinit {
        if running {
            stop()
        }
    }

    func start() {
        guard !running else {
            return
        }

        running = true

        if Freezer.startingPoints.count == 0 {
            Freezer.oldNSDateInit = replaceImplementation(_Selector("init"), newSelector: _Selector("newInit"))
            Freezer.oldNSDateInitWithTimeIntervalSinceNow =
                    replaceImplementation(_Selector("initWithTimeIntervalSinceNow:"),
                             newSelector: _Selector("newInitWithTimeIntervalSinceNow:"))

            let initWithRealNow = class_getInstanceMethod(NSClassFromString("__NSPlaceholderDate"),
                                                          _Selector("initWithTimeIntervalSinceRealNow:"))
            method_setImplementation(initWithRealNow, Freezer.oldNSDateInitWithTimeIntervalSinceNow)
        }

        Freezer.startingPoints.append(startingPoint)
    }

    func stop() {
        guard running else {
            return
        }

        for (idx, point) in Freezer.startingPoints.enumerate().reverse() {
            if point == self.startingPoint {
                Freezer.startingPoints.removeAtIndex(idx)
                break
            }
        }

        if Freezer.startingPoints.count == 0 {
            restoreImplementation(_Selector("init"), oldImplementation: Freezer.oldNSDateInit)
            restoreImplementation(_Selector("initWithTimeIntervalSinceNow:"), oldImplementation: Freezer.oldNSDateInitWithTimeIntervalSinceNow)
        }

        running = false
    }

    private func replaceImplementation(oldSelector: Selector, newSelector: Selector) -> IMP {
        let oldMethod = class_getInstanceMethod(NSClassFromString("__NSPlaceholderDate"), oldSelector)
        let oldImplementation = method_getImplementation(oldMethod)

        let newMethod = class_getInstanceMethod(NSDate.self, newSelector)
        let newImplementation = method_getImplementation(newMethod)

        method_setImplementation(oldMethod, newImplementation)

        return oldImplementation
    }

    private func restoreImplementation(selector: Selector, oldImplementation: IMP) {
        let method = class_getInstanceMethod(NSClassFromString("__NSPlaceholderDate"), selector)
        method_setImplementation(method, oldImplementation)
    }
}

public func freeze(time: NSDate, @noescape block: () -> ()) {
    let freezer = Freezer(to: time)
    freezer.start()
    block()
    freezer.stop()
}

public func timeshift(from: NSDate, @noescape block: () -> ()) {
    let freezer = Freezer(from: from)
    freezer.start()
    block()
    freezer.stop()
}
