//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class StatusTransactionParameterView: TransactionParameterView {

    var status: TransactionStatusParameter = .pending {
        didSet {
            update()
        }
    }

    override func update() {
        super.update()
        let statusString = NSAttributedString(string: status.stringValue,
                                              attributes:
            [
                NSAttributedString.Key.foregroundColor: status.colorValue
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
    case rejected

    var stringValue: String {
        switch self {
        case .failed: return LocalizedString("status_failed", comment: "'Failed' status")
        case .pending: return LocalizedString("status_pending", comment: "'Pending' status")
        case .success: return LocalizedString("status_success", comment: "'Success' status")
        case .rejected: return "" // rejected transactions are not displayed
        }
    }

    var colorValue: UIColor {
        switch self {
        case .failed, .rejected: return ColorName.tomato.color
        case .pending: return ColorName.mediumGrey.color
        case .success: return ColorName.hold.color
        }
    }
}
