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
        XCTAssertTrue(walletService.didCallEstimateSafeCreation)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, OnboardingTrackingEvent.createSafeFeeIntro)
    }

    func test_whenSelectingDescriptionInHeader_thenShowsAlert() {
        createWindow(controller)
        let headerView = controller.tableView(controller.tableView,
                                              viewForHeaderInSection: 0) as! CreationFeeIntroHeaderView
        headerView.onTextSelected!()
        XCTAssertAlertShown(message: OnboardingCreationFeeIntroViewController.Strings.Alert.description, actionCount: 1)
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

    func test_whenUpdatingEstimations_thenSetsPaymentMethodEstimatedTokenData() {
        walletService.feePaymentTokenData_output = TokenData.mgn.withBalance(1)
        let estimation1 = TokenData.gno.withBalance(100)
        let estimation2 = TokenData.mgn.withBalance(100)
        controller.update(with: [estimation1, estimation2])
        XCTAssertEqual(controller.paymentToken, estimation2)
    }

    func test_whenEstimationsDoesNotContainSelectedPaymentMethod_thenSetsSelectedMethodToEth() {
        walletService.feePaymentTokenData_output = TokenData.mgn.withBalance(1)
        let estimation1 = TokenData.Ether.withBalance(100)
        let estimation2 = TokenData.gno.withBalance(100)
        controller.update(with: [estimation1, estimation2])
        XCTAssertEqual(controller.paymentToken, estimation1)
        XCTAssertEqual(walletService.feePaymentTokenData, TokenData.Ether)
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

}
