//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import SafeUIKit

extension FeeCalculationAssetLine {

    func set(value: TokenData) {
        guard value.balance != nil else {
            tooltipSource?.message = nil
            set(value: SameTransferAndPaymentTokensFeeCalculation.Strings.loading)
            return
        }
        let formatter = TokenFormatter()
        set(value: formatter.string(from: value))
        set(tooltip: formatter.string(from: value, shortFormat: false))
    }

    func set(valueButton value: TokenData) {
        guard value.balance != nil else {
            tooltipSource?.message = nil
            set(value: SameTransferAndPaymentTokensFeeCalculation.Strings.loading)
            return
        }
        let formatter = TokenFormatter()
        set(valueButton: formatter.string(from: value), icon: nil)
    }

}
