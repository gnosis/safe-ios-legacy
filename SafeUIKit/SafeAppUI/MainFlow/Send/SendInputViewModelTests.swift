//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import CommonTestSupport
import Common

class SendInputViewModelTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    let walletAddress = "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14"
    let balance = BigInt(1_000)
    var model: SendInputViewModel!

    override func setUp() {
        super.setUp()
        walletService.assignAddress(walletAddress)
        walletService.update(account: ethID, newBalance: balance)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        model = SendInputViewModel(tokenID: ethID, processEventsOnMainThread: true) { /* empty */ }
        model.start()
    }

    func test_start() {
        XCTAssertEqual(model.balance, model.tokenFormatter.string(from: balance))
        XCTAssertEqual(model.amount, nil)
        XCTAssertEqual(model.recipient, nil)
        XCTAssertEqual(model.feeAmountTokenData.balance, 0)
        XCTAssertFalse(model.canProceedToSigning)
    }

    func test_whenWalletBalanceNil_thenBalanceIsNil() {
        walletService.update(account: ethID, newBalance: nil)
        model.start()
        XCTAssertEqual(model.balance, model.tokenFormatter.string(from: 0))
    }

    func test_whenAmountChangesToSameValue_nothingHappens() {
        var changed: Int = 0
        model = SendInputViewModel(tokenID: ethID) {
            changed += 1
        }
        model.start()
        model.change(amount: "a")
        let expected = changed
        model.change(amount: "a")
        XCTAssertEqual(changed, expected)
        XCTAssertGreaterThan(changed, 0)
    }

    func test_whenRecipientChangesToSameValue_nothingHappens() {
        var changed: Int = 0
        model = SendInputViewModel(tokenID: ethID) {
            changed += 1
        }
        model.start()
        model.change(recipient: "a")
        let expected = changed
        model.change(recipient: "a")
        XCTAssertEqual(changed, expected)
        XCTAssertGreaterThan(changed, 0)
    }

    func test_whenValidRecipient_thenEstimatesFees() {
        walletService.estimatedFee_output = 100
        model.change(recipient: walletAddress)
        delay()
        XCTAssertEqual(model.feeAmountTokenData.balance, -100)
        XCTAssertEqual(model.feeResultingBalanceTokenData.balance, balance - 100)
    }

    func test_whenEnteredAllValidData_thenCanProceedToSigning() {
        walletService.estimatedFee_output = 100
        model.change(amount: "0.0000000000000000001")
        model.change(recipient: walletAddress)
        delay()
        XCTAssertTrue(model.canProceedToSigning)
    }

    func test_whenNotEnoughFunds_thenCanNotProceedToSigning() {
        walletService.estimatedFee_output = 100
        model.change(amount: "1")
        model.change(recipient: walletAddress)
        delay()
        XCTAssertFalse(model.canProceedToSigning)
    }

}
