//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest


public func XCTAssertExist(_ element: @autoclosure () throws -> XCUIElement,
                           file: StaticString = #file,
                           line: UInt = #line) {
    XCTAssertPredicate(element, predicate: .exists, file: file, line: line)
}

public func XCTAssertNotExist(_ element: @autoclosure () throws -> XCUIElement,
                              file: StaticString = #file,
                              line: UInt = #line) {
    XCTAssertPredicate(element, predicate: .doesNotExist, file: file, line: line)
}

public func XCTAssertHittable(_ element: @autoclosure () throws -> XCUIElement,
                              file: StaticString = #file,
                              line: UInt = #line) {
    XCTAssertPredicate(element, predicate: .hittable, file: file, line: line)
}

public func XCTAssertNotHittable(_ element: @autoclosure () throws -> XCUIElement,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
    XCTAssertPredicate(element, predicate: .notHittable, file: file, line: line)
}

func XCTAssertPredicate(_ closure: @autoclosure () throws -> XCUIElement,
                        predicate: Predicate,
                        file: StaticString = #file,
                        line: UInt = #line) {
    do {
        let element = try closure()
        let nsPredicate = NSPredicate(format: "\(predicate.rawValue)")
        XCTAssertTrue(nsPredicate.evaluate(with: element),
                      "Element \(element) should satisfy \(nsPredicate) but it doesn't",
            file: file,
            line: line)
    } catch let e {
        XCTFail("\(e)", file: file, line: line)
    }
}
