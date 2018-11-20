//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class TokenAmountTransactionParameterView: TransactionParameterView {

    var style: TransactionValueStyle = .positive {
        didSet {
            setNeedsUpdate()
        }
    }

    override func update() {
        super.update()
        valueLabel.textColor = style.colorValue
    }

}
