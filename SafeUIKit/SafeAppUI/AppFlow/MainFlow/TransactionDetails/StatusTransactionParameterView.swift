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
        case .failed: return LocalizedString("transaction.details.status.failed", comment: "'Failed' status")
        case .pending: return LocalizedString("transaction.details.status.pending", comment: "'Pending' status")
        case .success: return LocalizedString("transaction.details.status.success", comment: "'Success' status")
        case .rejected: return LocalizedString("transaction.details.status.rejected", comment: "'Rejected' status")
        }
    }

    var colorValue: UIColor {
        switch self {
        case .failed, .rejected: return ColorName.tomato.color
        case .pending: return ColorName.battleshipGrey.color
        case .success: return ColorName.greenTeal.color
        }
    }
}
