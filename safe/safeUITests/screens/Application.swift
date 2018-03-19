//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class Application {

    private var arguments = [String]()

    func resetAllContentAndSettings() {
        arguments.append(ApplicationArguments.resetAllContentAndSettings)
    }

    func setPassword(_ password: String) {
        arguments.append(ApplicationArguments.setPassword)
        arguments.append(password)
    }

    func start() {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
    }

}
