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
        section.border = (2, ColorName.paleGrey.color)
        section.insets = UIEdgeInsets(top: 23, left: 16, bottom: 0, right: 16)
        set(contents: [section])
    }

}
