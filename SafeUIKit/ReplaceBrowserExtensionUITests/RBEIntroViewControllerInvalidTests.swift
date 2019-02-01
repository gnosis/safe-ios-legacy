//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerInvalidTests: RBEIntroViewControllerBaseTestCase {

    func test_whenInvalid_thenShowsError() {
        let error = FeeCalculationError.insufficientBalance
        vc.calculationData = CalculationData(currentBalance: "3 ETH", networkFee: "-4 ETH", balance: "-1 ETH")
        vc.transition(to: RBEIntroViewController.InvalidState(error: error))
        XCTAssertEqual(vc.feeCalculation.currentBalance.asset.value, "3 ETH")
        XCTAssertEqual(vc.feeCalculation.networkFee.asset.value, "-4 ETH")
        XCTAssertEqual(vc.feeCalculation.balance.asset.value, "-1 ETH")
        XCTAssertEqual(vc.feeCalculation.balance.asset.error as? FeeCalculationError, error)
        XCTAssertEqual(vc.feeCalculation.error?.text, error.localizedDescription)
    }

}
