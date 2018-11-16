//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import Common
import BigInt

class TransactionFeeViewTests: XCTestCase {

    let transactionFeeView = TransactionFeeView()
    let tokenData = TokenData(address: "", code: "TEST", name: "", logoURL: "", decimals: 5, balance: 123_456)
    let ethData = TokenData(address: "0x0", code: "ETH", name: "Ether", logoURL: "", decimals: 18, balance: 0)

    var wrapperView: UIStackView {
        return transactionFeeView.subviews.first { $0.accessibilityIdentifier == "wrapperStackView" } as! UIStackView
    }

    func test_whenTransactionFeeIsSet_thenItIsDisplayed() {
        transactionFeeView.configure(currentBalance: ethData, transactionFee: ethData, resultingBalance: ethData)
        XCTAssertEqual(wrapperView.arrangedSubviews.count, 4)

        let currentBalanceStackView = wrapperView.arrangedSubviews[0] as! UIStackView
        XCTAssertEqual(currentBalanceStackView.arrangedSubviews.count, 2)
        let currentBalanceLabel = currentBalanceStackView.arrangedSubviews[0] as! UILabel
        XCTAssertEqual(currentBalanceLabel.text, LocalizedString("transaction_fee.current_balance", comment: ""))
        XCTAssertEqual(currentBalanceLabel.font, UIFont.boldSystemFont(ofSize: 16))

        let transactionFeeStackView = wrapperView.arrangedSubviews[1] as! UIStackView
        XCTAssertEqual(transactionFeeStackView.arrangedSubviews.count, 2)
        let transactionFeeLabel = transactionFeeStackView.arrangedSubviews[0] as! UILabel
        XCTAssertEqual(transactionFeeLabel.text, LocalizedString("transaction_fee.transaction_fee", comment: ""))
        XCTAssertEqual(transactionFeeLabel.font, UIFont.systemFont(ofSize: 16))

        let resultingBalanceStackView = wrapperView.arrangedSubviews[3] as! UIStackView
        XCTAssertEqual(resultingBalanceStackView.arrangedSubviews.count, 2)
        let resultingBalanceLabel = resultingBalanceStackView.arrangedSubviews[0] as! UILabel
        XCTAssertEqual(resultingBalanceLabel.text,
                       LocalizedString("transaction_fee.balance_after_transfer", comment: ""))
        XCTAssertEqual(resultingBalanceLabel.font, UIFont.boldSystemFont(ofSize: 16))
    }

    func test_whenTransactionFeeIsNotSet_thenItIsNotDisplayed() {
        transactionFeeView.configure(currentBalance: tokenData, transactionFee: nil, resultingBalance: tokenData)
        XCTAssertEqual(wrapperView.arrangedSubviews.count, 2)

        let currentBalanceStackView = wrapperView.arrangedSubviews[0] as! UIStackView
        let currentBalanceLabel = currentBalanceStackView.arrangedSubviews[0] as! UILabel
        let balanceStr = LocalizedString("transaction_fee.current_balance", comment: "")
        let tokenStr = LocalizedString("transaction_fee.token", comment: "")
        XCTAssertEqual(currentBalanceLabel.text, balanceStr + " (\(tokenStr))")
        XCTAssertEqual(currentBalanceLabel.font, UIFont.boldSystemFont(ofSize: 16))

        let resultingBalanceStackView = wrapperView.arrangedSubviews[1] as! UIStackView
        XCTAssertEqual(resultingBalanceStackView.arrangedSubviews.count, 2)
        let resultingBalanceLabel = resultingBalanceStackView.arrangedSubviews[0] as! UILabel
        XCTAssertEqual(resultingBalanceLabel.text,
                       LocalizedString("transaction_fee.balance_after_transfer", comment: ""))
        XCTAssertEqual(resultingBalanceLabel.font, UIFont.boldSystemFont(ofSize: 16))
    }

    func test_whenCurrentBalanceIsNotSet_thenItIsNotDisplayed() {
        transactionFeeView.configure(currentBalance: nil, transactionFee: ethData, resultingBalance: ethData)
        XCTAssertEqual(wrapperView.arrangedSubviews.count, 2)

        let transactionFeeStackView = wrapperView.arrangedSubviews[0] as! UIStackView
        XCTAssertEqual(transactionFeeStackView.arrangedSubviews.count, 2)
        let transactionFeeLabel = transactionFeeStackView.arrangedSubviews[0] as! UILabel
        let feeStr = LocalizedString("transaction_fee.transaction_fee", comment: "")
        let etherStr = LocalizedString("transaction_fee.ether", comment: "")
        XCTAssertEqual(transactionFeeLabel.text, feeStr + " (\(etherStr))")
        XCTAssertEqual(transactionFeeLabel.font, UIFont.systemFont(ofSize: 16))

        let resultingBalanceStackView = wrapperView.arrangedSubviews[1] as! UIStackView
        XCTAssertEqual(resultingBalanceStackView.arrangedSubviews.count, 2)
        let resultingBalanceLabel = resultingBalanceStackView.arrangedSubviews[0] as! UILabel
        XCTAssertEqual(resultingBalanceLabel.text,
                       LocalizedString("transaction_fee.balance_after_transfer", comment: ""))
        XCTAssertEqual(resultingBalanceLabel.font, UIFont.systemFont(ofSize: 16))
    }

}
