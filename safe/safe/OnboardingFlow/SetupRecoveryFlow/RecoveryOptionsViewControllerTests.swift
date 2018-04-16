//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication

class RecoveryOptionsViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockSetupRecoveryOptionDelegate()
    private var controller: RecoveryOptionsViewController!

    override func setUp() {
        super.setUp()
        controller = RecoveryOptionsViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.mnemonicRecoveryButton)
    }

    func test_setupMnemonicRecovery_whenCalled_theDelegateCalled() {
        controller.setupMnemonicRecovery(self)
        XCTAssertTrue(delegate.hasSelectedMnemonicRecovery)
    }

    func test_whenRecoveryIsSet_thenNextEnabled() {
        let identityService = MockIdentityApplicationService()
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
        identityService.setUpRecovery()
        viewWillAppear()
        XCTAssertTrue(controller.nextButton.isEnabled)
    }

}

extension RecoveryOptionsViewControllerTests {

    private func viewWillAppear() {
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
}

class MockSetupRecoveryOptionDelegate: RecoveryOptionsDelegate {

    var hasSelectedMnemonicRecovery = false

    func didSelectMnemonicRecovery() {
        hasSelectedMnemonicRecovery = true
    }

}
