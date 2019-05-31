//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common

class OnboardingCreationFeeIntroViewControllerTests: SafeTestCase {

    var controller: OnboardingCreationFeeIntroViewController!
    // swiftlint:disable:next weak_delegate
    let delegate = MockCreationFeeIntroDelegate()

    override func setUp() {
        super.setUp()
        controller = OnboardingCreationFeeIntroViewController.create(delegate: delegate)
    }

    func test_whenCreated_thenFetchesEstimationData() {
        controller.viewWillAppear(false)
        delay()
        XCTAssertTrue(delegate.didCallEstimation)
    }

    func test_tracking() {
        controller.screenTrackingEvent = OnboardingTrackingEvent.createSafeFeeIntro
        XCTAssertTracksAppearance(in: controller, OnboardingTrackingEvent.createSafeFeeIntro)
    }

    func test_whenSelectingDescriptionInHeader_thenShowsAlert() {
        createWindow(controller)
        let headerView = controller.tableView(controller.tableView,
                                              viewForHeaderInSection: 0) as! CreationFeeIntroHeaderView
        headerView.onTextSelected!()
        XCTAssertAlertShown(message: delegate.creationFeeNetworkFeeAlert().message, actionCount: 1)
    }

    func test_whenChoosingToPay_thenCallsDelegate() {
        controller.viewDidLoad()
        controller.viewWillAppear(false)
        let footerView = controller.tableView(controller.tableView,
                                              viewForFooterInSection: 0) as! PaymentMethodFooterView
        footerView.pay(self)
        XCTAssertTrue(delegate.didSelectToPay)
    }

    func test_whenChoosingToChangePaymentMethod_thenCallsDelegate() {
        controller.viewDidLoad()
        controller.viewWillAppear(false)
        let footerView = controller.tableView(controller.tableView,
                                              viewForFooterInSection: 0) as! PaymentMethodFooterView
        footerView.changePaymentMethod(self)
        XCTAssertTrue(delegate.didSelectToChangePaymentMethod)
    }

}

class MockCreationFeeIntroDelegate: CreationFeeIntroDelegate {

    var didSelectToPay = false
    func creationFeeIntroPay() {
        didSelectToPay = true
    }

    var didSelectToChangePaymentMethod = false
    func creationFeeIntroChangePaymentMethod(estimations: [TokenData]) {
        didSelectToChangePaymentMethod = true
    }

    var didCallEstimation = false
    func creationFeeLoadEstimates() -> [TokenData] {
        didCallEstimation = true
        return []
    }

    func creationFeeNetworkFeeAlert() -> UIAlertController {
        return .creationFee()
    }
}
