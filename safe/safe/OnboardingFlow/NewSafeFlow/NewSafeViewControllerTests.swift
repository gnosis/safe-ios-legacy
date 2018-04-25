//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication
import CommonTestSupport
import safeUIKit

class NewSafeViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockNewSafeDelegate()
    private var controller: NewSafeViewController!

    override func setUp() {
        super.setUp()
        let draftSafe = try! identityService.createDraftSafe()
        controller = NewSafeViewController.create(draftSafe: draftSafe, delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.thisDeviceButton)
        XCTAssertNotNil(controller.browserExtensionButton)
        XCTAssertNotNil(controller.paperWalletButton)
        XCTAssertFalse(controller.thisDeviceButton.isEnabled)
    }

    func test_setupPaperWallet_callsDelegate() {
        controller.setupPaperWallet(self)
        XCTAssertTrue(delegate.hasSelectedPaperWalletSetup)
    }

    func test_setupBrowserExtension_callsDelegate() {
        controller.setupBrowserExtension(self)
        XCTAssertTrue(delegate.hasSelectedBrowserExtensionSetup)
    }

    func test_viewDidLoad_whenNoDraftSafe_thenDismissesAndLogs() {
        controller = NewSafeViewController.create(draftSafe: nil, delegate: delegate)
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
        XCTAssertTrue(logger.errorLogged)
    }

    func test_viewWillAppear_whenDraftSafeHasConfiguredAddress_thenCheckmarksAreSet() {
        let draftSafe = try! identityService.getOrCreateDraftSafe()
        controller.viewWillAppear(false)
        assertButtonCheckmarks(.selected, .normal, .normal)
        identityService.confirmPaperWallet(draftSafe: draftSafe)
        controller.viewWillAppear(false)
        assertButtonCheckmarks(.selected, .selected, .normal)
        identityService.confirmBrowserExtension(draftSafe: draftSafe, address: "test_address")
        controller.viewWillAppear(false)
        assertButtonCheckmarks(.selected, .selected, .selected)
    }

}

extension NewSafeViewControllerTests {

    private func assertButtonCheckmarks(_ thisDeviceCheckmark: BigButton.CheckmarkStatus,
                                        _ paperWalletCheckmark: BigButton.CheckmarkStatus,
                                        _ browserExtensionCheckmark: BigButton.CheckmarkStatus) {
        XCTAssertEqual(controller.thisDeviceButton.checkmarkStatus, thisDeviceCheckmark)
        XCTAssertEqual(controller.paperWalletButton.checkmarkStatus, paperWalletCheckmark)
        XCTAssertEqual(controller.browserExtensionButton.checkmarkStatus, browserExtensionCheckmark)
    }

}

class MockNewSafeDelegate: NewSafeDelegate {

    var hasSelectedPaperWalletSetup = false
    var hasSelectedBrowserExtensionSetup = false

    func didSelectPaperWalletSetup() {
        hasSelectedPaperWalletSetup = true
    }

    func didSelectBrowserExtensionSetup() {
        hasSelectedBrowserExtensionSetup = true
    }

}
