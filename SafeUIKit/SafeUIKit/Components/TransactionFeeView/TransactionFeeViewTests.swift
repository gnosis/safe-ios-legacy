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
    let ethData = TokenData.Ether

    func test_whenTransactionFeeIsSet_thenItIsDisplayed() {
        transactionFeeView.configure(currentBalance: ethData, transactionFee: ethData, resultingBalance: ethData)

        XCTAssertEqual(transactionFeeView.currentBalanceValueLabel?.text,
                       transactionFeeView.tokenFormatter.string(from: ethData.balance!))
        assertLabel(transactionFeeView.currentBalanceLabel,
                    localizedKey: "transaction_fee.current_balance",
                    boldFontSize: transactionFeeView.fontSize)


        XCTAssertEqual(transactionFeeView.transactionFeeValueLabel?.text,
                       transactionFeeView.tokenFormatter.string(from: ethData.balance!))
        assertLabel(transactionFeeView.transactionFeeLabel,
                    localizedKey: "transaction_fee.transaction_fee",
                    fontSize: transactionFeeView.fontSize)

        XCTAssertEqual(transactionFeeView.resultingBalanceValueLabel?.text,
                       transactionFeeView.tokenFormatter.string(from: ethData.balance!))
        assertLabel(transactionFeeView.resultingBalanceLabel,
                    localizedKey: "transaction_fee.balance_after_transfer",
                    boldFontSize: transactionFeeView.fontSize)
    }

    func test_whenTransactionFeeIsNotSet_thenItIsNotDisplayed() {
        transactionFeeView.configure(currentBalance: tokenData, transactionFee: nil, resultingBalance: tokenData)

        let balanceStr = LocalizedString("transaction_fee.current_balance", comment: "")
        let tokenStr = LocalizedString("transaction_fee.token", comment: "")
        assertLabel(transactionFeeView.currentBalanceLabel,
                    text: "\(balanceStr) (\(tokenStr))",
                    font: UIFont.boldSystemFont(ofSize: transactionFeeView.fontSize))

        assertLabel(transactionFeeView.resultingBalanceLabel,
                    localizedKey: "transaction_fee.balance_after_transfer",
                    boldFontSize: transactionFeeView.fontSize)
    }

    func test_whenCurrentBalanceIsNotSet_thenItIsNotDisplayed() {
        transactionFeeView.configure(currentBalance: nil, transactionFee: ethData, resultingBalance: ethData)

        let feeStr = LocalizedString("transaction_fee.transaction_fee", comment: "")
        let etherStr = LocalizedString("transaction_fee.ether", comment: "")
        assertLabel(transactionFeeView.transactionFeeLabel,
                    text: "\(feeStr) (\(etherStr))",
                    font: UIFont.systemFont(ofSize: transactionFeeView.fontSize))

        assertLabel(transactionFeeView.resultingBalanceLabel,
                    localizedKey: "transaction_fee.balance_after_transfer",
                    fontSize: transactionFeeView.fontSize)
    }

}

private extension TransactionFeeViewTests {

    func assertLabel(_ label: UILabel?, localizedKey: String, fontSize: CGFloat, line: UInt = #line) {
        assertLabel(label, localizedKey: localizedKey, font: .systemFont(ofSize: fontSize), line: line)
    }

    func assertLabel(_ label: UILabel?, localizedKey: String, font: UIFont, line: UInt = #line) {
        assertLabel(label, text: LocalizedString(localizedKey, comment: ""), font: font, line: line)
    }

    func assertLabel(_ label: UILabel?, localizedKey: String, boldFontSize: CGFloat, line: UInt = #line) {
        assertLabel(label, localizedKey: localizedKey, font: .boldSystemFont(ofSize: boldFontSize), line: line)
    }

    func assertLabel(_ label: UILabel?, text: String, font: UIFont, line: UInt = #line) {
        guard let label = label else {
            XCTFail()
            return
        }
        XCTAssertEqual(label.text, text, line: line)
        XCTAssertEqual(label.font, font, line: line)
    }

}
