//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class FeeRequestView: BaseCustomView {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var balanceStackView: UIStackView!

    @IBOutlet weak var amountReceivedStackView: UIStackView!
    @IBOutlet weak var amountReceivedLabel: UILabel!
    @IBOutlet weak var amountReceivedAmountLabel: AmountLabel!

    @IBOutlet weak var amountNeededStackView: UIStackView!
    @IBOutlet weak var amountNeededLabel: UILabel!
    @IBOutlet weak var amountNeededAmountLabel: AmountLabel!

    @IBOutlet weak var remainderStackView: UIStackView!
    @IBOutlet weak var remainderTextLabel: UILabel!
    @IBOutlet weak var remainderAmountLabel: AmountLabel!

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

        [amountReceivedLabel,
        amountReceivedAmountLabel,
        amountNeededLabel,
        amountNeededAmountLabel,
        remainderTextLabel].forEach { label in
            label?.textColor = ColorName.darkGrey.color
        }
        remainderAmountLabel.textColor = ColorName.darkBlue.color

        [remainderAmountLabel, amountReceivedAmountLabel, amountNeededAmountLabel].forEach { label in
            label?.isShowingPlusSign = false
            label?.hasTooltip = true
        }

        [remainderAmountLabel, amountNeededAmountLabel].forEach { label in
            label?.formatter.roundingBehavior = .roundUp
        }

        amountReceivedLabel.text = Strings.received
        amountNeededLabel.text = Strings.needed
    }

}
