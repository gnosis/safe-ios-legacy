//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import CommonTestSupport
import IdentityAccessApplication

class FatalErrorHandlerTests: XCTestCase {

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
        FatalErrorHandler.showFatalError(message: "Fatal error", log: "Fatal", error: nil)
        delay()
        XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController)
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return }
        XCTAssertEqual(vc.view.backgroundColor, .clear)
        XCTAssertNotNil(vc.presentedViewController)
        guard let alertVC = vc.presentedViewController as? UIAlertController else { return }
        XCTAssertEqual(alertVC.message, "Fatal error")
        XCTAssertEqual(alertVC.actions.count, 1)
        XCTAssertNotNil(alertVC.title)
        XCTAssertNotNil(alertVC.actions.first?.title)
    }

    func test_logsToLogger() {
        FatalErrorHandler.showFatalError(message: "error", log: "Fatal", error: nil)
        XCTAssertTrue(logger.fatalLogged)
    }

}
