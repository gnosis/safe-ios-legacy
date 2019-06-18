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
    func set(value: TokenData, roundUp: Bool = false) {
        guard value.balance != nil else {
            tooltipSource?.message = nil
            set(value: "\(SameTransferAndPaymentTokensFeeCalculation.Strings.loading) \(value.code)")
            return
        }
        let formatter = TokenFormatter()
        formatter.roundingBehavior = roundUp ? .roundUp : .cutoff
        set(value: formatter.localizedString(from: value))
        set(tooltip: formatter.localizedString(from: value, shortFormat: false))
    }

    /// Set actionable button in assets line. Currently is used for changing payment method.
    ///
    /// - Parameters:
    ///   - value: button token data.
    ///   - target: target for button action.
    ///   - action: button action.
    ///   - displayedDecimals: displayed decimals.
    func set(valueButton value: TokenData, target: Any? = nil, action: Selector? = nil, roundUp: Bool = false) {
        var valueButtonStr = value.code
        if value.balance != nil {
            let formatter = TokenFormatter()
            formatter.roundingBehavior = roundUp ? .roundUp : .cutoff
            valueButtonStr = formatter.localizedString(from: value)
        } else {
            tooltipSource?.message = nil
            valueButtonStr = "\(SameTransferAndPaymentTokensFeeCalculation.Strings.loading) \(value.code)"
        }
        set(valueButton: valueButtonStr, icon: nil, target: target, action: action)
    }

}
