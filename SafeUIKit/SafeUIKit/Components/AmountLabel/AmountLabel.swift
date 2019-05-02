//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class AmountLabel: BaseCustomLabel {

    public var formatter = TokenNumberFormatter.ERC20Token(decimals: 18)

    public var isShowingPlusSign: Bool = true {
        didSet {
            update()
        }
    }

    public var amount: TokenData? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        formatter.displayedDecimals = 4
        update()
    }

    public override func update() {
        text = formattedText()
    }

    private func formattedText() -> String? {
        guard let amount = amount else { return nil }
        formatter.plusSign = isShowingPlusSign ? "+ " : ""
        formatter.tokenCode = amount.code
        formatter.decimals = amount.decimals
        return formatter.string(from: amount.balance ?? 0)
    }

}
