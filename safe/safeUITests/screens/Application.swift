//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

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
        app.terminate()
    }
}
