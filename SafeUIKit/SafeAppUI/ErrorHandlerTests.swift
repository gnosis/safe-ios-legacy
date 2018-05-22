//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import CommonTestSupport
import IdentityAccessApplication

class ErrorHandlerTests: XCTestCase {

    let logger = MockLogger()
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: logger, for: Logger.self)
        window = UIApplication.shared.keyWindow
    }

    override func tearDown() {
        super.tearDown()
        window?.makeKeyAndVisible()
        delay()
    }

    func test_presentsWindow() {
        ErrorHandler.showFatalError(message: "Fatal error", log: "Fatal", error: nil)
        delay()
        assertAlertShown(message: "Fatal error")
    }

    private func assertAlertShown(message expectedMessage: String, line: UInt = #line) {
        XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController, line: line)
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return }
        XCTAssertEqual(vc.view.backgroundColor, .clear, line: line)
        XCTAssertNotNil(vc.presentedViewController, line: line)
        guard let alertVC = vc.presentedViewController as? UIAlertController else { return }
        XCTAssertEqual(alertVC.message, expectedMessage, line: line)
        XCTAssertEqual(alertVC.actions.count, 1, line: line)
        XCTAssertNotNil(alertVC.title, line: line)
        XCTAssertNotNil(alertVC.actions.first?.title, line: line)
    }

    func test_logsToLogger() {
        ErrorHandler.showFatalError(message: "error", log: "Fatal", error: nil)
        XCTAssertTrue(logger.fatalLogged)
    }

    func test_whenErrorPresented_thenShowsIt() {
        ErrorHandler.showError(message: "Error!", log: "Error", error: nil)
        delay()
        assertAlertShown(message: "Error!")
    }

}
