//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication

class NewSafeViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockSetupRecoveryOptionDelegate()
    private var controller: NewSafeViewController!

    override func setUp() {
        super.setUp()
        controller = NewSafeViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.paperWalletButton)
    }

    func test_setupMnemonicRecovery_whenCalled_theDelegateCalled() {
        controller.setupPaperWallet(self)
        XCTAssertTrue(delegate.hasSelectedPaperWallet)
    }

}

extension NewSafeViewControllerTests {

    private func viewWillAppear() {
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
}

class MockSetupRecoveryOptionDelegate: NewSafeDelegate {

    var hasSelectedPaperWallet = false

    func didSelectPaperWalletSetup() {
        hasSelectedPaperWallet = true
    }

}
