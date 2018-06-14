//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class StatusTransactionParameterView: TransactionParameterView {

    @IBInspectable
    var IBStatus: Int {
        get { return status.rawValue }
        set { setStatus(newValue) }
    }

    var status: TransactionStatusParameter = .pending {
        didSet {
            setNeedsUpdate()
        }
    }

    func setStatus(_ newValue: Int) {
        if let value = TransactionStatusParameter(rawValue: newValue) {
            status = value
        } else {
            status = .pending
        }
    }

    override func update() {
        super.update()
        let statusString = NSAttributedString(string: status.stringValue,
                                              attributes:
            [
                NSAttributedStringKey.foregroundColor: status.colorValue
            ])
        let otherString = NSAttributedString(string: " - \(value)")
        let valueString = NSMutableAttributedString()
        valueString.append(statusString)
        valueString.append(otherString)
        valueLabel.attributedText = valueString
    }

}

enum TransactionStatusParameter: Int {
    case failed = -1
    case pending
    case success

    var stringValue: String {
        switch self {
        case .failed: return "Failed"
        case .pending: return "Pending"
        case .success: return "Success"
        }
    }

    var colorValue: UIColor {
        switch self {
        case .failed: return ColorName.tomato.color
        case .pending: return ColorName.battleshipGrey.color
        case .success: return ColorName.greenTeal.color
        }
    }
}
