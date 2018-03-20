//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class UnlockScreen: SecureTextfieldScreen {

    override var title: XCUIElement {
        return XCUIApplication().staticTexts[XCLocalizedString("app.unlock.header")]
    }
    let countdown = XCUIApplication().staticTexts["countdown"]

    func string(from time: TimeInterval) -> String {
        return String(format: "00:%02.0f", time)
    }

}
