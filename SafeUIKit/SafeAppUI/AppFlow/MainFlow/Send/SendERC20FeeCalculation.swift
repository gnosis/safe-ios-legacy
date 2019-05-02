//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

class SendERC20FeeCalculation: SendEthFeeCalculation {

    var networkFeeBalance: FeeCalculationAssetLine
    var networkFeeResultingBalanceLine: FeeCalculationAssetLine
    var networkFeeBalanceErrorLine: FeeCalculationErrorLine

    required init() {
        networkFeeBalance = FeeCalculationAssetLine()
            .set(name: Strings.currentBalance)
            .set(value: Strings.loading)
        networkFeeResultingBalanceLine = FeeCalculationAssetLine()
            .set(style: .balance)
            .set(name: Strings.resultingBalance)
            .set(value: Strings.loading)
        networkFeeBalanceErrorLine = FeeCalculationErrorLine(text: Strings.loading)
        super.init()
    }

    func setFeeBalanceError(_ error: Error?) {
        networkFeeBalanceErrorLine.set(error: error)
        networkFeeResultingBalanceLine.set(error: error)
    }

    override func update() {
        let section = FeeCalculationSection([resultingBalanceLine,
                                             errorLine,
                                             FeeCalculationSpacingLine(spacing: 20),
                                             networkFeeBalance,
                                             networkFeeLine,
                                             networkFeeResultingBalanceLine,
                                             networkFeeBalanceErrorLine])
        section.border = nil
        section.insets = .zero
        elements = [section]
    }
}
