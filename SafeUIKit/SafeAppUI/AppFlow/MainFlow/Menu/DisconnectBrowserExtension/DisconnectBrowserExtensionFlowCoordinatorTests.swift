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
