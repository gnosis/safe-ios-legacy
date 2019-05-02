//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication

class DisconnectBrowserExtensionFlowCoordinatorTests: XCTestCase {

    func test_tracking() {
        let mockDisconnectService = MockDisconnectBrowserExtensionApplicationService()
        let mockWalletService = MockWalletApplicationService()
        mockWalletService.transactionData_output = TransactionData.tokenData(status: .readyToSubmit)
        ApplicationServiceRegistry.put(service: mockWalletService, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: mockDisconnectService,
                                       for: DisconnectBrowserExtensionApplicationService.self)

        let coordinator = DisconnectBrowserExtensionFlowCoordinator()
        coordinator.transactionID = "Some"

        let introEvent = coordinator.introViewController().screenTrackingEvent
            as? DisconnectBrowserExtensionTrackingEvent
        XCTAssertEqual(introEvent, .intro)

        let phraseEvent = coordinator.phraseInputViewController().screenTrackingEvent
            as? DisconnectBrowserExtensionTrackingEvent
        XCTAssertEqual(phraseEvent, .enterSeed)

        let reviewScreenEvent = coordinator.reviewViewController().screenTrackingEvent
            as? DisconnectBrowserExtensionTrackingEvent
        XCTAssertEqual(reviewScreenEvent, .review)

        let successEvent = coordinator.reviewViewController().successTrackingEvent
            as? DisconnectBrowserExtensionTrackingEvent
        XCTAssertEqual(successEvent, .success)
    }

}

class MockDisconnectBrowserExtensionApplicationService: DisconnectBrowserExtensionApplicationService {

    override var isAvailable: Bool { return false }

    override func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        // no-op
    }

    override func create() -> RBETransactionID {
        return "Some"
    }

    override func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        return RBEEstimationResult(feeCalculation: nil, error: nil)
    }

    override func start(transaction: RBETransactionID) throws {
        // no-op
    }

    override func connect(transaction: RBETransactionID, code: String) throws {
        // no-op
    }

    override func startMonitoring(transaction: RBETransactionID) {
        // no-op
    }
}
