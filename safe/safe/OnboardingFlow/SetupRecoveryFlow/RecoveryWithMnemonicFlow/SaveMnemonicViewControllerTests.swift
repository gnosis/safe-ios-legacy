//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessDomainModel
import CommonTestSupport

class SaveMnemonicViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockSaveMnemonicDelegate()
    private var controller: SaveMnemonicViewController!

    override func setUp() {
        super.setUp()
        controller = SaveMnemonicViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.mnemonicCopyableLabel)
        XCTAssertNotNil(controller.saveButton)
        XCTAssertNotNil(controller.descriptionLabel)
        XCTAssertNotNil(controller.continueButton)
    }

    func test_viewDidLoad_setsCorrectMnemonic() throws {
        let mnemonicStr = "test mnemonic"
        try secureStore.saveMnemonic(Mnemonic(mnemonicStr))
        controller.viewDidLoad()
        XCTAssertEqual(controller.mnemonicCopyableLabel.text, mnemonicStr)
    }

    func test_viewDidLoad_dismissesIfNoEOAisSet() throws {
        try secureStore.removeMnemonic()
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

}

final class MockSaveMnemonicDelegate: SaveMnemonicDelegate {}
