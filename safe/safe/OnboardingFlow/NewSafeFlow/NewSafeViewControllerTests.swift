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
        let draftSafe = try! identityService.getOrCreateDraftSafe()
        controller = NewSafeViewController.create(draftSafe: draftSafe, delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.thisDeviceButton)
        XCTAssertNotNil(controller.chromeExtensionButton)
        XCTAssertNotNil(controller.paperWalletButton)
        XCTAssertFalse(controller.thisDeviceButton.isEnabled)
    }

    func test_setupPaperWallet_callsDelegate() {
        controller.setupPaperWallet(self)
        XCTAssertTrue(delegate.hasSelectedPaperWalletSetup)
    }

    func test_setupChromeExtension_callsDelegate() {
        controller.setupChromeExtension(self)
        XCTAssertTrue(delegate.hasSelectedChromeExtensionSetup)
    }

    func test_viewDidLoad_whenNoDraftSafe_thenDismissesAndLogs() {
        controller = NewSafeViewController.create(draftSafe: nil, delegate: delegate)
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
        XCTAssertTrue(logger.errorLogged)
    }

    func test_viewDidLoad_whenDraftSafeHasConfiguredAddress_thenCheckmarksAreSet() {
        let draftSafe = try! identityService.getOrCreateDraftSafe()
        controller.viewDidLoad()
        assertButtonCheckmarks(.selected, .normal, .normal)
        identityService.confirmPaperWallet(draftSafe: draftSafe)
        controller.viewDidLoad()
        assertButtonCheckmarks(.selected, .selected, .normal)
        identityService.confirmChromeExtension(draftSafe: draftSafe)
        controller.viewDidLoad()
        assertButtonCheckmarks(.selected, .selected, .selected)
    }

}

extension NewSafeViewControllerTests {

    private func viewWillAppear() {
        UIApplication.shared.keyWindow?.rootViewController = controller
    }

    private func createWindow(_ controller: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
    }

    private func assertButtonCheckmarks(_ thisDeviceCheckmark: BigButton.CheckmarkStatus,
                                        _ paperWalletCheckmark: BigButton.CheckmarkStatus,
                                        _ chromeExtensionCheckmark: BigButton.CheckmarkStatus) {
        XCTAssertEqual(controller.thisDeviceButton.checkmarkStatus, thisDeviceCheckmark)
        XCTAssertEqual(controller.paperWalletButton.checkmarkStatus, paperWalletCheckmark)
        XCTAssertEqual(controller.chromeExtensionButton.checkmarkStatus, chromeExtensionCheckmark)
    }

}

class MockNewSafeDelegate: NewSafeDelegate {

    var hasSelectedPaperWalletSetup = false
    var hasSelectedChromeExtensionSetup = false

    func didSelectPaperWalletSetup() {
        hasSelectedPaperWalletSetup = true
    }

    func didSelectChromeExtensionSetup() {
        hasSelectedChromeExtensionSetup = true
    }

}
