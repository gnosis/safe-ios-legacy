//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AppFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: AppFlowCoordinator!
    let account = MockAccount()

    override func setUp() {
        super.setUp()
        flowCoordinator = AppFlowCoordinator(account: account)
    }

    func test_startViewController_whenPasswordWasNotSet_thenPresentingOnboarding() {
        account.hasMasterPassword = false
        let root = flowCoordinator.startViewController()
        XCTAssertTrue(type(of: root) == type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

    func test_startViewController_whenPasswordWasSet_thenNotPresentingOnboarding() {
        account.hasMasterPassword = true
        let root = flowCoordinator.startViewController()
        XCTAssertTrue(type(of: root) != type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

}
