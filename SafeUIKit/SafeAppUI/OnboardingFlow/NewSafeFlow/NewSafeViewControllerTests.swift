//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import CommonTestSupport
import SafeUIKit

class NewSafeViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockNewSafeDelegate()
    private var controller: NewSafeViewController!

    override func setUp() {
        super.setUp()
        walletService.createNewDraftWallet()
        controller = NewSafeViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.thisDeviceButton)
        XCTAssertNotNil(controller.browserExtensionButton)
        XCTAssertNotNil(controller.paperWalletButton)
        XCTAssertFalse(controller.thisDeviceButton.isEnabled)
        XCTAssertFalse(controller.nextButton.isEnabled)
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
        walletService.removeSelectedWallet()
        controller = NewSafeViewController.create(delegate: delegate)
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
        XCTAssertTrue(logger.errorLogged)
    }

    func test_viewWillAppear_whenDraftSafeHasConfiguredAddress_thenCheckmarksAreSet() {
        walletService.addOwner(address: "address", type: .thisDevice)
        controller.viewWillAppear(false)
        assertButtonCheckmarks(.selected, .normal, .normal)

        walletService.addOwner(address: "address", type: .paperWallet)
        controller.viewWillAppear(false)
        assertButtonCheckmarks(.selected, .selected, .normal)

        walletService.addOwner(address: "address", type: .browserExtension)
        controller.viewWillAppear(false)
        assertButtonCheckmarks(.selected, .selected, .selected)
    }

    func test_viewWillAppear_whenDraftIsReady_thenNextButtonIsEnabled() {
        walletService.createReadyToDeployWallet()
        controller.viewWillAppear(false)
        XCTAssertTrue(controller.nextButton.isEnabled)
    }

    func test_navigateNext_callsDelegate() {
        controller.navigateNext(self)
        XCTAssertTrue(delegate.nextSelected)
    }

    func test_whenNavigatesNext_thenDeploymentStarted() {
        walletService.createReadyToDeployWallet()
        controller.navigateNext(self)
        XCTAssertEqual(walletService.selectedWalletState, .deploymentStarted)
    }

}

extension NewSafeViewControllerTests {

    private func assertButtonCheckmarks(_ thisDeviceCheckmark: BigButton.CheckmarkStatus,
                                        _ paperWalletCheckmark: BigButton.CheckmarkStatus,
                                        _ browserExtensionCheckmark: BigButton.CheckmarkStatus,
                                        line: UInt = #line) {
        XCTAssertEqual(controller.thisDeviceButton.checkmarkStatus, thisDeviceCheckmark, line: line)
        XCTAssertEqual(controller.paperWalletButton.checkmarkStatus, paperWalletCheckmark, line: line)
        XCTAssertEqual(controller.browserExtensionButton.checkmarkStatus, browserExtensionCheckmark, line: line)
    }

}

class MockNewSafeDelegate: NewSafeDelegate {

    var hasSelectedPaperWalletSetup = false
    var hasSelectedBrowserExtensionSetup = false
    var nextSelected = false

    func didSelectPaperWalletSetup() {
        hasSelectedPaperWalletSetup = true
    }

    func didSelectBrowserExtensionSetup() {
        hasSelectedBrowserExtensionSetup = true
    }

    func didSelectNext() {
        nextSelected = true
    }

}
