//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit

class SameTransferAndPaymentTokensFeeCalculation: FeeCalculation {

    enum Strings {

        static let currentBalance = LocalizedString("safe_balance", comment: "Current balance")
        static let networkFee = LocalizedString("transaction_fee", comment: "Network fee")
        static let resultingBalance = LocalizedString("balance_after_transfer", comment: "Balance after transfer")
        static let loading = "-"
        static let feeInfo = "[?]"

    }

    var networkFeeLine: FeeCalculationAssetLine
    var resultingBalanceLine: FeeCalculationAssetLine
    var errorLine: FeeCalculationErrorLine

    required init() {
        networkFeeLine = FeeCalculationAssetLine()
            .set(name: Strings.networkFee)
            .set(value: Strings.loading)
            .set(button: Strings.feeInfo,
                 target: nil,
                 action: #selector(ReviewTransactionViewController.showTransactionFeeInfo))
        resultingBalanceLine = FeeCalculationAssetLine()
            .set(style: .balance)
            .set(name: Strings.resultingBalance)
            .set(value: Strings.loading)
        errorLine = FeeCalculationErrorLine(text: "")
        super.init()
        update()
    }

    func setBalanceError(_ error: Error?) {
        errorLine.set(error: error)
        resultingBalanceLine.set(error: error)
    }

    override func update() {
        let section = FeeCalculationSection([networkFeeLine, resultingBalanceLine, errorLine])
        set(contents: [section])
    }

}
