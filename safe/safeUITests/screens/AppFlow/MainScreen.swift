//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class MainScreen {

    var isDisplayed: Bool { return identiconView.exists }
    var ethCell: XCUIElement { return XCUIApplication().cells["Ether"] }
    var identiconView: XCUIElement { return XCUIApplication().images["identicon"] }

}
