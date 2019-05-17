//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import SafeUIKit

extension FeeCalculationAssetLine {

    /// Set value in asset line.
    ///
    /// - Parameters:
    ///   - value: button token data.
    ///   - displayedDecimals: displayed decimals.
    func set(value: TokenData, displayedDecimals: Int = 5) {
        guard value.balance != nil else {
            tooltipSource?.message = nil
            set(value: SameTransferAndPaymentTokensFeeCalculation.Strings.loading)
            return
        }
        let formatter = TokenFormatter()
        set(value: formatter.string(from: value))
        set(tooltip: formatter.string(from: value, shortFormat: false))
    }

    /// Set actionable button in assets line. Currently is used for changing payment method.
    ///
    /// - Parameters:
    ///   - value: button token data.
    ///   - target: target for button action.
    ///   - action: button action.
    ///   - displayedDecimals: displayed decimals.
    func set(valueButton value: TokenData, target: Any? = nil, action: Selector? = nil, displayedDecimals: Int = 5) {
        var valueButtonStr = value.code
        if value.balance != nil {
            let formatter = TokenFormatter()
            valueButtonStr = formatter.string(from: value)
        } else {
            tooltipSource?.message = nil
        }
        set(valueButton: valueButtonStr, icon: nil, target: target, action: action)
    }

}
