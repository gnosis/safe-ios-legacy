//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

@IBDesignable
class TokenAmountTransactionParameterView: TransactionParameterView {

    @IBInspectable
    var IBStyle: Int {
        get { return style.rawValue }
        set {
            setStyle(newValue)
        }
    }

    var style: TransactionValueStyle = .positive {
        didSet {
            setNeedsUpdate()
        }
    }

    func setStyle(_ newValue: Int) {
        if let value = TransactionValueStyle(rawValue: newValue) {
            style = value
        } else {
            style = .neutral
        }
    }

    override func update() {
        super.update()
        valueLabel.textColor = style.colorValue
    }

}
