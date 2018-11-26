//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class AmountLabel: BaseCustomLabel {

    public var formatter = TokenNumberFormatter.ERC20Token(decimals: 18)

    public var amount: TokenData? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        formatter.plusSign = "+ "
        formatter.minusSign = "- "
        formatter.displayedDecimals = 4
        update()
    }

    public override func update() {
        guard let amount = amount else {
            text = nil
            return
        }
        formatter.tokenCode = amount.code
        formatter.decimals = amount.decimals
        text = formatter.string(from: amount.balance ?? 0)
    }

}
