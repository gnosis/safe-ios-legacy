//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import SafeUIKit

extension FeeCalculationAssetLine {

    func set(value: TokenData, displayedDecimals: Int = 5) {
        guard let balance = value.balance else {
            set(value: SendEthFeeCalculation.Strings.loading)
            return
        }
        let formatter = TokenNumberFormatter.ERC20Token(code: value.code,
                                                        decimals: value.decimals,
                                                        displayedDecimals: displayedDecimals)
        set(value: formatter.string(from: balance))
    }

}
