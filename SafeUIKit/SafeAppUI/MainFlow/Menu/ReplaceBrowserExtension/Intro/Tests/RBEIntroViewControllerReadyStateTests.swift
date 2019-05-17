//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import BigInt
import MultisigWalletApplication

class RBEIntroViewControllerReadyStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenReady_thenPrepared() {
        vc.calculationData = RBEFeeCalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(3e18)),
                                                   networkFee: TokenData.Ether.withBalance(BigInt(-4e18)),
                                                   balance: TokenData.Ether.withBalance(BigInt(-1e18)))
        vc.showRetry()
        vc.disableStart()
        vc.transition(to: RBEIntroViewController.ReadyState())
        XCTAssertEqual(vc.feeCalculation.currentBalanceLine.asset.value, "3 ETH")
        XCTAssertEqual(vc.feeCalculation.networkFeeLine.asset.value, "-")
        XCTAssertEqual(vc.feeCalculation.resultingBalanceLine.asset.value, "-1 ETH")
        XCTAssertNil(vc.feeCalculation.resultingBalanceLine.asset.error)
        XCTAssertNotNil(vc.feeCalculation.errorLine)
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertTrue(vc.startButtonItem.isEnabled)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
    }

}
