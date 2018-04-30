//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class NewSafeScreenUITests: XCTestCase {

    let application = Application()
    let password = "11111A"
    let screen = NewSafeScreen()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.resetAllContentAndSettings()
        application.setPassword(password)
        application.start()
        let unlock = UnlockScreen()
        unlock.enterPassword(password)
        let setupOptions = SetupSafeOptionsScreen()
        setupOptions.newSafe.tap()
    }

    func test_contents() {
        XCTAssertTrue(screen.isDisplayed)
        XCTAssertExist(screen.thisDevice.element)
        XCTAssertFalse(screen.thisDevice.enabled)
        XCTAssertTrue(screen.thisDevice.isChecked)
        XCTAssertExist(screen.browserExtension.element)
        XCTAssertFalse(screen.browserExtension.isChecked)
        XCTAssertExist(screen.paperWallet.element)
        XCTAssertFalse(screen.paperWallet.isChecked)
    }

}
