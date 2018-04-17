//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication
import CommonTestSupport

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
