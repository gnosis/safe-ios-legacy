//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class MainScreen {

    var isDisplayed: Bool { return balanceLabel.exists }
    var balanceLabel: XCUIElement { return XCUIApplication().staticTexts["main.label.balance"] }

}
