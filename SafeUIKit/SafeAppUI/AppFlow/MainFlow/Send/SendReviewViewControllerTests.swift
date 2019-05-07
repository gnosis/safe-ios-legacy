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
        XCTAssertEqual(transferViewCell.transferView.balanceData, data.amountTokenData.withBalance(accountBalance))
    }

    func test_whenLoadedForEth_thenHasCorrectFees() {
        let (data, vc) = ethDataAndCotroller()

        let balance = service.accountBalance(tokenID: BaseID(data.amountTokenData.address))!
        let resultingBalance = balance - data.amountTokenData.balance! - data.feeTokenData.balance!
        let formatter = TokenNumberFormatter.create(data: data.amountTokenData)

        let cell = vc.cellForRow(vc.cellCount() - 2) as! FeeCalculationCell
        let calculation = cell.feeCalculationView.calculation as! SendEthFeeCalculation

        XCTAssertEqual(calculation.networkFeeLine.asset.value,
                       formatter.string(from: data.feeTokenData.withNonNegativeBalance().balance!))
        XCTAssertEqual(calculation.resultingBalanceLine.asset.value,
                       formatter.string(from: resultingBalance))
    }

    func test_whenLoadedForToken_thenHasCorrectFees() {
        let (data, vc) = tokenDataAndCotroller()

        let tokenBalance = service.accountBalance(tokenID: BaseID(data.amountTokenData.address))!
        let tokenResultingBalance = tokenBalance - data.amountTokenData.balance!
        let tokenFormatter = TokenNumberFormatter.create(data: data.amountTokenData)

        let feeBalance = service.accountBalance(tokenID: BaseID(data.feeTokenData.address))!
        let feeResultingBalance = feeBalance - data.feeTokenData.balance!
        let feeFormatter = TokenNumberFormatter.create(data: data.feeTokenData)

        let cell = vc.cellForRow(vc.cellCount() - 2) as! FeeCalculationCell
        let calculation = cell.feeCalculationView.calculation as! SendERC20FeeCalculation

        XCTAssertEqual(calculation.resultingBalanceLine.asset.value,
                       tokenFormatter.string(from: tokenResultingBalance))
        XCTAssertEqual(calculation.networkFeeLine.asset.value,
                       feeFormatter.string(from: data.feeTokenData.balance!))
        XCTAssertEqual(calculation.networkFeeResultingBalanceLine.asset.value,
                       feeFormatter.string(from: feeResultingBalance))
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

extension TokenNumberFormatter {

    static func create(data: TokenData) -> TokenNumberFormatter {
        return TokenNumberFormatter.ERC20Token(code: data.code,
                                               decimals: data.decimals,
                                               displayedDecimals: 5)
    }
}
