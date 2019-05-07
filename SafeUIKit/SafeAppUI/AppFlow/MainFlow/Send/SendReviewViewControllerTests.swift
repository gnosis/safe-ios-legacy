//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import SafeUIKit

class SendReviewViewControllerTests: ReviewTransactionViewControllerTests {

    func test_whenLoaded_thenSetsTransferViewAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let transferViewCell = vc.cellForRow(0) as! TransferViewCell
        XCTAssertEqual(transferViewCell.transferView.fromAddress, data.sender)
        XCTAssertEqual(transferViewCell.transferView.toAddress, data.recipient)
        XCTAssertEqual(transferViewCell.transferView.tokenData, data.amountTokenData)
    }

    // MARK: - Tracking

    func test_whenHasExtension_thenTracks() {
        XCTAssertTracks { handler in
            let (_, vc) = ethDataAndCotroller()
            service.addOwner(address: "test", type: .browserExtension)

            vc.viewDidAppear(false)

            let tokenAddress = vc.tx.amountTokenData.address
            let tokenCode = vc.tx.amountTokenData.code

            XCTAssertEqual(handler.screenName(at: 0), SendTrackingEvent.ScreenName.review2FARequired.rawValue)
            XCTAssertEqual(handler.parameter(at: 0, name: SendTrackingEvent.tokenParameterName), tokenAddress)
            XCTAssertEqual(handler.parameter(at: 0, name: SendTrackingEvent.tokenNameParameterName), tokenCode)
        }
    }

    func test_whenChangesStates_thenTracks() {
        XCTAssertTracks { handler in
            let (_, vc) = ethDataAndCotroller()

            vc.didConfirm()
            XCTAssertEqual(handler.screenName(at: 0), SendTrackingEvent.ScreenName.review2FAConfirmed.rawValue)

            vc.didReject()
            XCTAssertEqual(handler.screenName(at: 1), SendTrackingEvent.ScreenName.review2FARejected.rawValue)

            vc.didSubmit()
            XCTAssertEqual(handler.screenName(at: 2), SendTrackingEvent.ScreenName.success.rawValue)
        }
    }

}
