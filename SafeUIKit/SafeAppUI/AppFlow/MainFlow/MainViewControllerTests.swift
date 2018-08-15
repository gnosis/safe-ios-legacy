//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common
import BigInt

class MainViewControllerTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    // swiftlint:disable weak_delegate
    let delegate = MockMainViewControllerDelegate()
    var vc: MainViewController!
    let ethID = BaseID("0x0000000000000000000000000000000000000000")

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)

        vc = MainViewController.create(delegate: delegate)
    }

    func test_whenPressingSend_thenCallsDelegate() {
        createWindow(vc)
        vc.sendButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(delegate.didCallCreateNewTransaction)
    }

    func test_whenLoaded_loadsBalance() {
        walletService.update(account: ethID, newBalance: BigInt(1e9))
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.totalBalanceLabel.text, "0,000000001 ETH")
    }

}

class MockMainViewControllerDelegate: MainViewControllerDelegate {

    var didCallCreateNewTransaction = false

    func mainViewDidAppear() {}

    func createNewTransaction() {
        didCallCreateNewTransaction = true
    }

}
