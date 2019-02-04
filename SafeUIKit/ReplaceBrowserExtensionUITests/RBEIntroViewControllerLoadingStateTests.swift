//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerLoadingStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenLoading_thenHasContent() {
        vc.enableStart()
        vc.transition(to: RBEIntroViewController.LoadingState())
        XCTAssertTrue(vc.navigationItem.titleView is LoadingTitleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
        XCTAssertFalse(vc.startButtonItem.isEnabled)
        XCTAssertEqual(vc.navigationItem.leftBarButtonItems, [vc.backButtonItem])
    }

    func test_whenLoading_thenHasEmptyCalculation() {
        XCTAssertEqual(vc.feeCalculationView.calculation, EthFeeCalculation())
    }
    
}
