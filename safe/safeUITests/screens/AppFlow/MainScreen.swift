//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class MainScreen {

    var isDisplayed: Bool { return sendButton.exists }
    var sendButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("main.send")] }
    var receiveButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("main.receive")] }

}
