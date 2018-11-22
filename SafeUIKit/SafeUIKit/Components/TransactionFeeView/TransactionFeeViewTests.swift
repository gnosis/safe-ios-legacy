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
    let ethData = TokenData.Ether.copy(balance: 1)

    var wrapperView: UIStackView {
        return transactionFeeView.subviews.first { $0.accessibilityIdentifier == "wrapperStackView" } as! UIStackView
    }

    func test_whenTransactionFeeIsSet_thenItIsDisplayed() {
        transactionFeeView.configure(currentBalance: ethData, transactionFee: ethData, resultingBalance: ethData)

        XCTAssertEqual(wrapperView.arrangedSubviews.count,
                       4,
                       "Current balance stack, transaction fee stack, spacing view, resulting balance stack")

        XCTAssertEqual(transactionFeeView.currentBalanceValueLabel?.text,
                       transactionFeeView.tokenFormatter.string(from: ethData.balance!))
        assertLabel(transactionFeeView.currentBalanceLabel,
                    localizedKey: "transaction_fee.current_balance",
                    boldFontSize: 16)


        XCTAssertEqual(transactionFeeView.transactionFeeValueLabel?.text,
                       transactionFeeView.tokenFormatter.string(from: ethData.balance!))
        assertLabel(transactionFeeView.transactionFeeLabel,
                    localizedKey: "transaction_fee.transaction_fee",
                    fontSize: 16)

        XCTAssertEqual(transactionFeeView.resultingBalanceValueLabel?.text,
                       transactionFeeView.tokenFormatter.string(from: ethData.balance!))
        assertLabel(transactionFeeView.resultingBalanceLabel,
                    localizedKey: "transaction_fee.balance_after_transfer",
                    boldFontSize: 16)
    }

    private func assertLabel(_ label: UILabel?, localizedKey: String, fontSize: CGFloat) {
        assertLabel(label, localizedKey: localizedKey, font: .systemFont(ofSize: fontSize))
    }

    private func assertLabel(_ label: UILabel?, localizedKey: String, font: UIFont) {
        guard let label = label else {
            XCTFail()
            return
        }
        XCTAssertEqual(label.text, LocalizedString(localizedKey, comment: ""))
        XCTAssertEqual(label.font, font)
    }

    private func assertLabel(_ label: UILabel?, localizedKey: String, boldFontSize: CGFloat) {
        assertLabel(label, localizedKey: localizedKey, font: .boldSystemFont(ofSize: boldFontSize))
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
