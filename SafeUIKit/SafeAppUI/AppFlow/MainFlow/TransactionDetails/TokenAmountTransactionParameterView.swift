//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

class TokenAmountTransactionParameterView: TransactionParameterView {

    var amount: TokenData? {
        didSet {
            amountLabel.amount = amount
        }
    }

    var amountLabel: AmountLabel! {
        return valueLabel as! AmountLabel
    }

    override func newValueLabel() -> UILabel {
        return AmountLabel()
    }

}
