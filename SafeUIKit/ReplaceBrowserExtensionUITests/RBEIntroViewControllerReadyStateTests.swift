//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI
import Common
import BigInt

class RBEIntroViewControllerReadyStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenReady_thenPrepared() {
        vc.calculationData = CalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(3e18)),
                                             networkFee: TokenData.Ether.withBalance(BigInt(-4e18)),
                                             balance: TokenData.Ether.withBalance(BigInt(-1e18)))
        vc.showRetry()
        vc.disableStart()
        vc.transition(to: RBEIntroViewController.ReadyState())
        XCTAssertEqual(vc.feeCalculation.currentBalance.asset.value, "3.00 ETH")
        XCTAssertEqual(vc.feeCalculation.networkFee.asset.value, "- 4.00 ETH")
        XCTAssertEqual(vc.feeCalculation.balance.asset.value, "- 1.00 ETH")
        XCTAssertNil(vc.feeCalculation.balance.asset.error)
        XCTAssertNil(vc.feeCalculation.error)
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertTrue(vc.startButtonItem.isEnabled)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
    }

}
