//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common

class OnboardingPaymentMethodViewControllerTests: SafeTestCase {

    var controller: OnboardingPaymentMethodViewController!
    // swiftlint:disable:next weak_delegate
    let delegate = MockCreationFeePaymentMethodDelegate()

    override func setUp() {
        super.setUp()
        controller = OnboardingPaymentMethodViewController.create(delegate: delegate, estimations: [])
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, OnboardingTrackingEvent.createSafePaymentMethod)
    }

    func test_whenNoEstimations_thenFetchesThem() {
        XCTAssertFalse(walletService.didCallEstimateSafeCreation)
        controller.updateData()
        delay()
        XCTAssertTrue(walletService.didCallEstimateSafeCreation)
    }

    func test_whenUpdatingTheFirstTimeWithKnownEstimations_thenDoesNotFetchEstimations() {
        XCTAssertFalse(walletService.didCallEstimateSafeCreation)
        updateWithKnownEstimations()
        XCTAssertFalse(walletService.didCallEstimateSafeCreation)
    }

    func test_whenUpdatingTheSecondTime_thenFetchesEstimations() {
        updateWithKnownEstimations()
        controller.updateData()
        delay()
        XCTAssertTrue(walletService.didCallEstimateSafeCreation)
    }

    func test_whenEstimationsAreKnown_thenDoesNotSetLoadingTitle() {
        controller = OnboardingPaymentMethodViewController.create(delegate: delegate, estimations: [TokenData.Ether])
        controller.viewDidLoad()
        XCTAssertNil(controller.navigationItem.titleView)
    }

    func test_whenNoEstimations_thenSetsLoadingTitle() {
        controller.viewDidLoad()
        XCTAssertNotNil(controller.navigationItem.titleView)
    }

    func test_whenEstimationsAreFetched_thenHidesLoadingTitle() {
        controller.viewDidLoad()
        walletService.estimateSafeCreation_output = [TokenData.Ether]
        controller.updateData()
        delay()
        XCTAssertNil(controller.navigationItem.titleView)
    }

    func test_whenSelectingRow_thenChangesPaymentToken() {
        controller = OnboardingPaymentMethodViewController.create(delegate: delegate,
                                                                  estimations: [TokenData.Ether, TokenData.gno])
        XCTAssertEqual(walletService.feePaymentTokenData, TokenData.Ether)
        selectRow(1)
        XCTAssertEqual(walletService.feePaymentTokenData, TokenData.gno)
    }

    func test_whenSelectingRow_thenUpdatesButtonTitle() {
        controller = OnboardingPaymentMethodViewController.create(delegate: delegate,
                                                                  estimations: [TokenData.Ether, TokenData.gno])
        let ethTitle = String(format: OnboardingPaymentMethodViewController.Strings.payWith, TokenData.Ether.code)
        let gnoTitle = String(format: OnboardingPaymentMethodViewController.Strings.payWith, TokenData.gno.code)
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.payButton.title(for: .normal), ethTitle)
        selectRow(1)
        XCTAssertEqual(controller.payButton.title(for: .normal), gnoTitle)
    }

    func test_whenChoosingToPay_thenCallsDelegate() {
        controller.pay()
        XCTAssertTrue(delegate.didSelectToPay)
    }

    private func updateWithKnownEstimations() {
        controller = OnboardingPaymentMethodViewController.create(delegate: delegate, estimations: [TokenData.Ether])
        controller.updateData()
        delay()
    }

    private func selectRow(_ row: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: 0))
    }

}

class MockCreationFeePaymentMethodDelegate: CreationFeePaymentMethodDelegate {

    var didSelectToPay = false
    func creationFeePaymentMethodPay() {
        didSelectToPay = true
    }

}
