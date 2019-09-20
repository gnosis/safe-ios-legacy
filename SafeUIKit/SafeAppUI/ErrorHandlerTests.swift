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
    let controller = UIViewController()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: logger, for: Logger.self)
        window = UIApplication.shared.keyWindow
        window.rootViewController = controller
    }

    override func tearDown() {
        super.tearDown()
        window?.makeKeyAndVisible()
        delay()
    }

    func test_presentsWindow() {
        ErrorHandler.showFatalError(message: "Fatal error", log: "Fatal", error: nil, from: controller)
        delay()
        XCTAssertAlertShown(message: "Fatal error")
    }

    func test_logsToLogger() {
        ErrorHandler.showFatalError(message: "error", log: "Fatal", error: nil, from: controller)
        XCTAssertTrue(logger.fatalLogged)
    }

}
