//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI
import Common
import BigInt

class RBEIntroViewControllerInvalidStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenInvalid_thenShowsError() {
        let error = FeeCalculationError.insufficientBalance
        vc.calculationData = CalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(3e18)),
                                             networkFee: TokenData.Ether.withBalance(BigInt(-4e18)),
                                             balance: TokenData.Ether.withBalance(BigInt(-1e18)))
        vc.disableRetry()
        vc.transition(to: RBEIntroViewController.InvalidState(error: error))
        XCTAssertEqual(vc.feeCalculation.currentBalance.asset.value, "3.00 ETH")
        XCTAssertEqual(vc.feeCalculation.networkFee.asset.value, "- 4.00 ETH")
        XCTAssertEqual(vc.feeCalculation.balance.asset.value, "- 1.00 ETH")
        XCTAssertEqual(vc.feeCalculation.balance.asset.error as? FeeCalculationError, error)
        XCTAssertEqual(vc.feeCalculation.error?.text, error.localizedDescription)
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertTrue(vc.retryButtonItem.isEnabled)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.retryButtonItem])
    }

    func test_whenOhterError_thenDisplaysIt() {
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorTimedOut,
                            userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
        vc.transition(to: RBEIntroViewController.InvalidState(error: error))
        XCTAssertEqual(vc.feeCalculation.error?.text, error.localizedDescription)
        XCTAssertNil(vc.feeCalculation.balance.asset.error)
    }

}

