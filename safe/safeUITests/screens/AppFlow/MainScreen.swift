//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class MainScreen {

    var isDisplayed: Bool { return addressLabel.exists }
    var addressLabel: XCUIElement {return XCUIApplication().staticTexts[LocalizedString("main.label.address")] }
    var balanceLabel: XCUIElement {return XCUIApplication().staticTexts[LocalizedString("main.label.balance")] }

}
