//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit

class DifferentTransferAndPaymentTokensFeeCalculation: SameTransferAndPaymentTokensFeeCalculation {

    var networkFeeResultingBalanceLine: FeeCalculationAssetLine
    var networkFeeBalanceErrorLine: FeeCalculationErrorLine

    required init() {
        networkFeeResultingBalanceLine = FeeCalculationAssetLine()
            .set(style: .balance)
            .set(name: Strings.resultingBalance)
            .set(value: Strings.loading)
        networkFeeBalanceErrorLine = FeeCalculationErrorLine(text: "")
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
                                             networkFeeLine,
                                             networkFeeResultingBalanceLine,
                                             networkFeeBalanceErrorLine])
        set(contents: [section])
    }
}
