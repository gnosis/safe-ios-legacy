//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common

class MainViewControllerTests: XCTestCase {

    func test_whenPressingSend_thenCallsDelegate() {
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        ApplicationServiceRegistry.put(service: MockWalletApplicationService(), for: WalletApplicationService.self)
        let delegate = MockMainViewControllerDelegate()
        let vc = MainViewController.create(delegate: delegate)
        createWindow(vc)
        vc.sendButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(delegate.didCallCreateNewTransaction)
    }

}

class MockMainViewControllerDelegate: MainViewControllerDelegate {

    var didCallCreateNewTransaction = false

    func mainViewDidAppear() {}

    func createNewTransaction() {
        didCallCreateNewTransaction = true
    }

}
