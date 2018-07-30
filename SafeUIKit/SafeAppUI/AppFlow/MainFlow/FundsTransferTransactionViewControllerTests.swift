//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt

class FundsTransferTransactionViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func disabled_test_whenLoaded_thenShowsBalance() {
        let walletService = MockWalletApplicationService()
        let walletAddress = "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14"
        walletService.assignAddress(walletAddress)

        let balance = BigInt(1_000)

        walletService.update(account: "ETH", newBalance: Int(balance))

        let maxWei = BigInt(10).power(18)
        let (integerPart, remainder) = balance.quotientAndRemainder(dividingBy: maxWei)
        let remainderString = String(remainder)
        let padded = String(repeating: "0", count: 18 - remainderString.count) + remainderString
        let fractionalPart = ("$" + padded).trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropFirst()

        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        let controller = FundsTransferTransactionViewController.create()
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.participantView.address, walletAddress)
        XCTAssertEqual(controller.participantView.name, "Safe")
        XCTAssertEqual(controller.valueView.tokenAmount, "\(integerPart),\(fractionalPart) ETH")
    }

}
