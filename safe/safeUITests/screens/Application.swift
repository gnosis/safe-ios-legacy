//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class Application {

    private var arguments = [String]()
    private let app = XCUIApplication()

    func resetAllContentAndSettings() {
        arguments.append(ApplicationArguments.resetAllContentAndSettings)
    }

    func setPassword(_ password: String) {
        arguments.append(ApplicationArguments.setPassword)
        arguments.append(password)
    }

    func setSessionDuration(seconds duration: TimeInterval) {
        arguments.append(ApplicationArguments.setSessionDuration)
        arguments.append(String(duration))
    }

    func setMaxPasswordAttempts(_ attemptCount: Int) {
        arguments.append(ApplicationArguments.setMaxPasswordAttempts)
        arguments.append(String(attemptCount))
    }

    func setAccountBlockedPeriodDuration(_ time: TimeInterval) {
        arguments.append(ApplicationArguments.setAccountBlockedPeriodDuration)
        arguments.append(String(time))
    }

    func start() {
        app.launchArguments = arguments
        app.launch()
    }

    func minimize() {
        XCUIDevice.shared.press(.home)
    }

    func maximize() {
        app.activate()
    }

    func terminate() {
        // give some time to save data
        delay(1)
        app.terminate()
    }
}
