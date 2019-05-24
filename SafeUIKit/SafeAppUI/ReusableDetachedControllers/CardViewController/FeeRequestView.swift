//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class FeeRequestView: BaseCustomView {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var balanceStackView: UIStackView!

    // TODO: rename to amountReceived
    @IBOutlet weak var balanceLineStackView: UIStackView!
    @IBOutlet weak var balanceLineLabel: UILabel!
    @IBOutlet weak var balanceLineAmountLabel: AmountLabel!

    // TODO: rename to amountNeded
    @IBOutlet weak var totalLineStackView: UIStackView!
    @IBOutlet weak var totalLineLabel: UILabel!
    @IBOutlet weak var totalLineAmountLabel: AmountLabel!

    // TODO: rename to remainder
    @IBOutlet weak var feeStackView: UIStackView!
    @IBOutlet weak var feeTextLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: AmountLabel!

    enum Strings {
        static let received = LocalizedString("amount_received", comment: "Received")
        static let needed = LocalizedString("amount_needed", comment: "Needed")
        static let sendFeeRequest = LocalizedString("this_is_your_permanent_address", comment: "This is address")
        static let sendRemainderRequest = LocalizedString("send_remainder", comment: "Send the remainder")
    }

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: FeeRequestView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView)

        [balanceLineLabel,
        balanceLineAmountLabel,
        totalLineLabel,
        totalLineAmountLabel,
        feeTextLabel].forEach { label in
            label?.textColor = ColorName.battleshipGrey.color
        }
        feeAmountLabel.textColor = ColorName.darkSlateBlue.color
    }

}
