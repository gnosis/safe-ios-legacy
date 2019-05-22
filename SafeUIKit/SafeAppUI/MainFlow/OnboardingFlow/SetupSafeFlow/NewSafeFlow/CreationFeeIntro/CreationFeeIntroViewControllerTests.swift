//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class CreationFeeIntroViewControllerTests: SafeTestCase {

    var controller: CreationFeeIntroViewController!
    // swiftlint:disable:next weak_delegate
    let delegate = MockCreationFeeIntroDelegate()

    override func setUp() {
        super.setUp()
        controller = CreationFeeIntroViewController.create(delegate: delegate)
    }

    func test_whenCreated_thenFetchesEstimationData() {
        controller.viewWillAppear(false)
        delay()
        XCTAssertTrue(walletService.didCallEstimateSafeCreation)
    }

//    func test_tracking() {
//        XCTAssertTracksAppearance(in: controller, MenuTrackingEvent.feePaymentMethod)
//    }

//    func test_whenSelectingDescriptionInHeader_thenShowsAlert() {
//        createWindow(controller)
//        let headerView = controller.tableView(controller.tableView,
//                                              viewForHeaderInSection: 0) as! PaymentMethodHeaderView
//        headerView.onTextSelected!()
//        XCTAssertAlertShown(message: PaymentMethodViewController.Strings.Alert.description, actionCount: 1)
//    }

    func test_whenChoosingToPay_thenCallsDelegate() {
        controller.viewDidLoad()
        let footerView = controller.tableView(controller.tableView,
                                              viewForFooterInSection: 0) as! PaymentMethodFooterView
        footerView.pay(self)
        XCTAssertTrue(delegate.didSelectToPay)
    }

    func test_whenChoosingToChangePaymentMethod_thenCallsDelegate() {
        controller.viewDidLoad()
        let footerView = controller.tableView(controller.tableView,
                                              viewForFooterInSection: 0) as! PaymentMethodFooterView
        footerView.changePaymentMethod(self)
        XCTAssertTrue(delegate.didSelectToChangePaymentMethod)
    }

}

class MockCreationFeeIntroDelegate: CreationFeeIntroDelegate {

    var didSelectToPay = false
    func didSelectPay() {
        didSelectToPay = true
    }

    var didSelectToChangePaymentMethod = false
    func didSelectChangePaymentMethod() {
        didSelectToChangePaymentMethod = true
    }

}
