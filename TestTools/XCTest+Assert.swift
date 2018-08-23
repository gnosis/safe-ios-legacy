    //
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
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

public func XCTAssertAlertShown(message expectedMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
    XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController, file: file, line: line)
    guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return }
    XCTAssertNotNil(vc.presentedViewController, file: file, line: line)
    let alert = (vc.presentedViewController as? UIAlertController) ??
        (vc.presentedViewController?.presentedViewController as? UIAlertController)
    XCTAssertNotNil(alert)
    guard let alertVC = alert else { return }
    if let expectedMessage = expectedMessage {
        XCTAssertEqual(alertVC.message, expectedMessage, file: file, line: line)
    }
    XCTAssertEqual(alertVC.actions.count, 1, file: file, line: line)
    XCTAssertNotNil(alertVC.title, file: file, line: line)
    XCTAssertNotNil(alertVC.actions.first?.title, file: file, line: line)
    if let action = alertVC.actions.first {
        action.test_handler?(action)
    }
}

