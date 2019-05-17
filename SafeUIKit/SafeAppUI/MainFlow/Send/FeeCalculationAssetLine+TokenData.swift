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
        guard let balance = value.balance else {
            tooltipSource?.message = nil
            set(value: SameTransferAndPaymentTokensFeeCalculation.Strings.loading)
            return
        }
        let formatter = TokenNumberFormatter.ERC20Token(code: value.code,
                                                        decimals: value.decimals,
                                                        displayedDecimals: displayedDecimals)
        set(value: formatter.string(from: balance))

        formatter.displayedDecimals = nil
        set(tooltip: formatter.string(from: balance))
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
        if let balance = value.balance {
            let formatter = TokenNumberFormatter.ERC20Token(code: value.code,
                                                            decimals: value.decimals,
                                                            displayedDecimals: displayedDecimals)
            valueButtonStr = formatter.string(from: balance)
        } else {
            tooltipSource?.message = nil
        }
        set(valueButton: valueButtonStr, icon: nil, target: target, action: action)
    }

}
