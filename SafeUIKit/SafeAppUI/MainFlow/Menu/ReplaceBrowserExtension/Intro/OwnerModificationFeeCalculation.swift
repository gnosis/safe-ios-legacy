//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class OwnerModificationFeeCalculation: SameTransferAndPaymentTokensFeeCalculation {

    var currentBalanceLine: FeeCalculationAssetLine

    required init() {
        currentBalanceLine = FeeCalculationAssetLine()
            .set(name: Strings.currentBalance)
            .set(value: Strings.loading)
        super.init()
        update()
    }

    override func update() {
        let section = FeeCalculationSection([currentBalanceLine, networkFeeLine, resultingBalanceLine, errorLine])
        section.border = nil
        set(contents: [section])
    }

}
