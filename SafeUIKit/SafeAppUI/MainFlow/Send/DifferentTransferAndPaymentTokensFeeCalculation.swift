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
        let section = FeeCalculationSection([networkFeeLine,
                                             networkFeeResultingBalanceLine,
                                             networkFeeBalanceErrorLine,
                                             FeeCalculationSpacingLine(spacing: 20),
                                             resultingBalanceLine,
                                             errorLine])
        section.border = nil
        section.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        set(contents: [section])
    }
}
