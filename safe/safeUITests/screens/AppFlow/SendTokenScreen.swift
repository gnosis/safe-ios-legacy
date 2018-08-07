//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

import XCTest

class SendTokenScreen {

    var isDisplayed: Bool { return continueButton.exists }
    var continueButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("transaction.continue")] }

}
