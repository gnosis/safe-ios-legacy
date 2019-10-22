//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import UIKit

public func XCTAssertAlertShown(message expectedMessage: String? = nil,
                                actionCount: Int = 1,
                                file: StaticString = #file,
                                line: UInt = #line) {
    XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController, file: file, line: line)
    guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return }
    XCTAssertNotNil(vc.presentedViewController, file: file, line: line)
    let alert = (vc.presentedViewController as? UIAlertController) ??
        (vc.presentedViewController?.presentedViewController as? UIAlertController)
    XCTAssertNotNil(alert, file: file, line: line)
    guard let alertVC = alert else { return }
    if let expectedMessage = expectedMessage {
        XCTAssertEqual(alertVC.message, expectedMessage, file: file, line: line)
    }
    XCTAssertEqual(alertVC.actions.count, actionCount, file: file, line: line)
    XCTAssertNotNil(alertVC.title, file: file, line: line)
    XCTAssertNotNil(alertVC.actions.first?.title, file: file, line: line)
    if let action = alertVC.actions.first {
        action.test_handler?(action)
    }
}
