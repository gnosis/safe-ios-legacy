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
    }

    func test_whenLoadingAndPushed_thenBackButtonIsSet() {
        let navVC = UINavigationController(rootViewController: UIViewController())
        navVC.pushViewController(vc, animated: false)
        vc.transition(to: RBEIntroViewController.LoadingState())
        vc.willMove(toParent: navVC)
        XCTAssertEqual(navVC.viewControllers.first!.navigationItem.backBarButtonItem, vc.backButtonItem)
    }

    func test_whenMovingToRootVC_thenOK() {
        let navVC = UINavigationController()
        navVC.setViewControllers([vc], animated: false)
        XCTAssertNil(vc.navigationItem.backBarButtonItem)
    }

    func test_whenMovingToNonNavigationParent_thenOK() {
        let parent = UIViewController()
        parent.addChild(vc)
        XCTAssertNil(vc.navigationItem.backBarButtonItem)
        XCTAssertNil(parent.navigationItem.backBarButtonItem)
    }

    func test_whenLoading_thenHasEmptyCalculation() {
        XCTAssertEqual(vc.feeCalculationView.calculation, EthFeeCalculation())
    }
    
}
